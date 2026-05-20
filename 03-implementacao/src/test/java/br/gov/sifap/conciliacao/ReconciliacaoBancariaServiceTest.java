package br.gov.sifap.conciliacao;

import br.gov.sifap.auditoria.AuditoriaService;
import br.gov.sifap.pagamento.Pagamento;
import br.gov.sifap.pagamento.PagamentoRepository;
import br.gov.sifap.pagamento.SituacaoPagamento;
import br.gov.sifap.pagamento.SituacaoConciliacao;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Testes unitários para a reconciliação bancária (CNAB 240 / Banco do Brasil).
 *
 * Rastreabilidade:
 *   REQ-020 — Conciliação de pagamento confirmado    (BATCHCON.NSN)
 *   REQ-021 — Tratamento de divergências e não encontrados
 *   REQ-022 — Auditoria imutável de divergências
 *
 * Regras extraídas de BATCHCON.NSN (legado SIFAP 2000-2014).
 * QA PAR 4 — 2026-05-20
 */
@DisplayName("REQ-020/021/022 — Reconciliação bancária CNAB 240")
@ExtendWith(MockitoExtension.class)
class ReconciliacaoBancariaServiceTest {

    @Mock
    private PagamentoRepository pagamentoRepository;

    @Mock
    private AuditoriaService auditoriaService;

    @InjectMocks
    private ReconciliacaoBancariaService reconciliacaoService;

    private static final LocalDate COMPETENCIA = LocalDate.of(2026, 5, 1);

    // =========================================================================
    // REQ-020 — Conciliação bem-sucedida
    // =========================================================================

    @Nested
    @DisplayName("REQ-020 — Pagamento conciliado com sucesso")
    class ConciliacaoSucesso {

        @Test
        @DisplayName("pagamento com valor igual ao retorno bancário deve ter status CONFIRMADO")
        void pagamentoComValorIgualDeveSerConfirmado() {
            // Arrange
            Pagamento pgto = criarPagamento("1000001", "11111111111", new BigDecimal("600.00"));
            when(pagamentoRepository.findByNumPagamento(1000001L)).thenReturn(Optional.of(pgto));

            RegistroCnab240 registro = criarRegistroCnab("1000001", "11111111111",
                new BigDecimal("600.00"), "00");

            // Act
            ResultadoConciliacao resultado = reconciliacaoService.processar(registro, COMPETENCIA);

            // Assert
            assertThat(resultado.getSituacao()).isEqualTo(SituacaoConciliacao.CONCILIADO);
            verify(pagamentoRepository).save(argThat(p ->
                p.getSituacao() == SituacaoPagamento.CONFIRMADO
                && p.getDtConfirmacao() != null
            ));
        }

        @Test
        @DisplayName("diferença de até R$ 0,01 deve ser aceita como conciliado")
        void diferencaAteCentavoDeveSerConciliado() {
            // Regra do legado: IF #DIFF > 0.01 → divergência (BATCHCON.NSN ~linha 150)
            Pagamento pgto = criarPagamento("1000002", "22222222222", new BigDecimal("600.00"));
            when(pagamentoRepository.findByNumPagamento(1000002L)).thenReturn(Optional.of(pgto));

            RegistroCnab240 registro = criarRegistroCnab("1000002", "22222222222",
                new BigDecimal("600.01"), "00");

            ResultadoConciliacao resultado = reconciliacaoService.processar(registro, COMPETENCIA);

            assertThat(resultado.getSituacao()).isEqualTo(SituacaoConciliacao.CONCILIADO);
        }

        @Test
        @DisplayName("diferença exatamente de R$ 0,01 deve ser aceita como conciliado")
        void diferencaExatamenteCentavoDeveSerConciliado() {
            Pagamento pgto = criarPagamento("1000003", "33333333333", new BigDecimal("600.00"));
            when(pagamentoRepository.findByNumPagamento(1000003L)).thenReturn(Optional.of(pgto));

            RegistroCnab240 registro = criarRegistroCnab("1000003", "33333333333",
                new BigDecimal("599.99"), "00");

            ResultadoConciliacao resultado = reconciliacaoService.processar(registro, COMPETENCIA);

            assertThat(resultado.getSituacao()).isEqualTo(SituacaoConciliacao.CONCILIADO);
        }
    }

    // =========================================================================
    // REQ-021 — Divergências e não encontrados
    // =========================================================================

    @Nested
    @DisplayName("REQ-021 — Divergências e registros não encontrados")
    class Divergencias {

        @Test
        @DisplayName("diferença acima de R$ 0,01 deve ser marcada como DIVERGENTE")
        void diferencaAcimaCentavoDeveDivergir() {
            Pagamento pgto = criarPagamento("1000004", "44444444444", new BigDecimal("600.00"));
            when(pagamentoRepository.findByNumPagamento(1000004L)).thenReturn(Optional.of(pgto));

            RegistroCnab240 registro = criarRegistroCnab("1000004", "44444444444",
                new BigDecimal("550.00"), "00");  // diferença = 50,00 > 0,01

            ResultadoConciliacao resultado = reconciliacaoService.processar(registro, COMPETENCIA);

            assertThat(resultado.getSituacao()).isEqualTo(SituacaoConciliacao.DIVERGENTE);
            // Status do pagamento NÃO deve ser alterado
            verify(pagamentoRepository, never()).save(argThat(p ->
                p.getSituacao() == SituacaoPagamento.CONFIRMADO
            ));
        }

        @Test
        @DisplayName("pagamento não encontrado pelo num_pagamento deve retornar NAO_ENCONTRADO")
        void pagamentoNaoEncontradoDeveRetornarNaoEncontrado() {
            when(pagamentoRepository.findByNumPagamento(9999999L)).thenReturn(Optional.empty());

            RegistroCnab240 registro = criarRegistroCnab("9999999", "55555555555",
                new BigDecimal("600.00"), "00");

            ResultadoConciliacao resultado = reconciliacaoService.processar(registro, COMPETENCIA);

            assertThat(resultado.getSituacao()).isEqualTo(SituacaoConciliacao.NAO_ENCONTRADO);
            verify(pagamentoRepository, never()).save(any());
        }

        @Test
        @DisplayName("CPF do CNAB diferente do CPF do pagamento deve retornar NAO_ENCONTRADO")
        void cpfDivergentEnoCnabDeveRetornarNaoEncontrado() {
            // Pagamento pertence ao CPF 11111111111
            Pagamento pgto = criarPagamento("1000005", "11111111111", new BigDecimal("600.00"));
            when(pagamentoRepository.findByNumPagamento(1000005L)).thenReturn(Optional.of(pgto));

            // CNAB traz CPF diferente — possível fraude ou erro de layout
            RegistroCnab240 registro = criarRegistroCnab("1000005", "99999999999",
                new BigDecimal("600.00"), "00");

            ResultadoConciliacao resultado = reconciliacaoService.processar(registro, COMPETENCIA);

            assertThat(resultado.getSituacao()).isEqualTo(SituacaoConciliacao.NAO_ENCONTRADO);
        }
    }

    // =========================================================================
    // REQ-022 — Auditoria imutável (BATCHCON.NSN + IN-TCU 63/2010)
    // =========================================================================

    @Nested
    @DisplayName("REQ-022 — Auditoria imutável de divergências")
    class AuditoriaDivergencia {

        @Test
        @DisplayName("toda divergência deve gerar registro de auditoria com ação AL")
        void divergenciaDeveGerarAuditoria() {
            Pagamento pgto = criarPagamento("1000006", "66666666666", new BigDecimal("600.00"));
            when(pagamentoRepository.findByNumPagamento(1000006L)).thenReturn(Optional.of(pgto));

            RegistroCnab240 registro = criarRegistroCnab("1000006", "66666666666",
                new BigDecimal("400.00"), "00");

            reconciliacaoService.processar(registro, COMPETENCIA);

            verify(auditoriaService).registrar(argThat(evento ->
                "AL".equals(evento.getCodAcao())
                && "PGTO".equals(evento.getTipoEntidade())
                && "1000006".equals(evento.getIdEntidade())
                && evento.getDesAcao() != null
                && evento.getDesAcao().contains("DIVERGENCIA")
            ));
        }

        @Test
        @DisplayName("pagamento conciliado com sucesso também gera auditoria AL")
        void conciliacaoSucessoTambemGeraAuditoria() {
            Pagamento pgto = criarPagamento("1000007", "77777777777", new BigDecimal("600.00"));
            when(pagamentoRepository.findByNumPagamento(1000007L)).thenReturn(Optional.of(pgto));

            RegistroCnab240 registro = criarRegistroCnab("1000007", "77777777777",
                new BigDecimal("600.00"), "00");

            reconciliacaoService.processar(registro, COMPETENCIA);

            verify(auditoriaService).registrar(argThat(evento ->
                "AL".equals(evento.getCodAcao())
                && "BATCHCON".equals(evento.getCodModulo())
            ));
        }

        @Test
        @DisplayName("auditoria nunca deve ser chamada com operação DELETE ou UPDATE direta")
        void auditoriaDeveSempreUsarInsert() {
            // O serviço de auditoria NUNCA deve chamar métodos de remoção ou alteração de registros
            // Verificamos que apenas o método 'registrar' (INSERT) é invocado
            Pagamento pgto = criarPagamento("1000008", "88888888888", new BigDecimal("600.00"));
            when(pagamentoRepository.findByNumPagamento(1000008L)).thenReturn(Optional.of(pgto));

            RegistroCnab240 registro = criarRegistroCnab("1000008", "88888888888",
                new BigDecimal("400.00"), "00");

            reconciliacaoService.processar(registro, COMPETENCIA);

            // Verifica que apenas 'registrar' foi chamado — nunca deletar/atualizar
            verify(auditoriaService, atLeastOnce()).registrar(any());
            verify(auditoriaService, never()).deletar(any());
            verify(auditoriaService, never()).atualizar(any());
        }
    }

    // =========================================================================
    // REQ-020 — Relatório consolidado do ciclo de reconciliação
    // =========================================================================

    @Nested
    @DisplayName("REQ-020 — Contadores do relatório final")
    class RelatorioFinal {

        @Test
        @DisplayName("relatório final deve somar corretamente conciliados, divergentes e não encontrados")
        void relatorioFinalDeveEstarConsistente() {
            // Arrange — 3 pagamentos: 2 OK, 1 divergente
            Pagamento p1 = criarPagamento("2000001", "10000000001", new BigDecimal("600.00"));
            Pagamento p2 = criarPagamento("2000002", "10000000002", new BigDecimal("600.00"));
            Pagamento p3 = criarPagamento("2000003", "10000000003", new BigDecimal("600.00"));

            when(pagamentoRepository.findByNumPagamento(2000001L)).thenReturn(Optional.of(p1));
            when(pagamentoRepository.findByNumPagamento(2000002L)).thenReturn(Optional.of(p2));
            when(pagamentoRepository.findByNumPagamento(2000003L)).thenReturn(Optional.of(p3));
            when(pagamentoRepository.findByNumPagamento(9000000L)).thenReturn(Optional.empty());

            java.util.List<RegistroCnab240> registros = java.util.List.of(
                criarRegistroCnab("2000001", "10000000001", new BigDecimal("600.00"), "00"),  // OK
                criarRegistroCnab("2000002", "10000000002", new BigDecimal("600.01"), "00"),  // OK (tolerância)
                criarRegistroCnab("2000003", "10000000003", new BigDecimal("550.00"), "00"),  // divergente
                criarRegistroCnab("9000000", "10000000004", new BigDecimal("600.00"), "00")   // não encontrado
            );

            // Act
            RelatorioReconciliacao relatorio = reconciliacaoService.executarCiclo(registros, COMPETENCIA);

            // Assert
            assertThat(relatorio.getQtdLidos()).isEqualTo(4);
            assertThat(relatorio.getQtdConciliados()).isEqualTo(2);
            assertThat(relatorio.getQtdDivergentes()).isEqualTo(1);
            assertThat(relatorio.getQtdNaoEncontrados()).isEqualTo(1);
            // invariante: lidos = conciliados + divergentes + não encontrados
            assertThat(relatorio.getQtdLidos())
                .isEqualTo(relatorio.getQtdConciliados()
                    + relatorio.getQtdDivergentes()
                    + relatorio.getQtdNaoEncontrados());
        }
    }

    // =========================================================================
    // Helpers
    // =========================================================================

    private Pagamento criarPagamento(String numPagamento, String cpf, BigDecimal vlrLiquido) {
        Pagamento p = new Pagamento();
        p.setNumPagamento(Long.parseLong(numPagamento));
        p.setCpfBeneficiario(cpf);
        p.setVlrLiquido(vlrLiquido);
        p.setVlrBruto(vlrLiquido);
        p.setSituacao(SituacaoPagamento.EMITIDO);
        return p;
    }

    private RegistroCnab240 criarRegistroCnab(String numDoc, String cpf,
                                               BigDecimal valor, String codigoRetorno) {
        RegistroCnab240 r = new RegistroCnab240();
        r.setNumDoc(numDoc);
        r.setCpf(cpf);
        r.setValor(valor);
        r.setCodigoRetorno(codigoRetorno);
        r.setDtPagamento(LocalDate.of(2026, 5, 15));
        return r;
    }
}
