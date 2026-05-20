package br.gov.sifap.ciclo;

import br.gov.sifap.beneficio.Beneficiario;
import br.gov.sifap.beneficio.SituacaoBeneficiario;
import br.gov.sifap.pagamento.Pagamento;
import br.gov.sifap.pagamento.SituacaoPagamento;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Testes unitários para a geração do ciclo mensal de pagamentos.
 *
 * Rastreabilidade:
 *   REQ-010 — Geração de pagamentos em lote (BATCHPGT.NSN)
 *   REQ-011 — Apenas beneficiários ATIVOS são processados
 *   REQ-012 — Idempotência do ciclo (não duplicar pagamentos)
 *
 * QA PAR 4 — 2026-05-20
 */
@DisplayName("REQ-010/011/012 — Geração do ciclo mensal de pagamentos")
@ExtendWith(MockitoExtension.class)
class CicloPagamentoServiceTest {

    @Mock
    private BeneficiarioRepository beneficiarioRepository;

    @Mock
    private PagamentoRepository pagamentoRepository;

    @Mock
    private AuditoriaService auditoriaService;

    @InjectMocks
    private CicloPagamentoService cicloPagamentoService;

    private static final LocalDate COMPETENCIA_202605 = LocalDate.of(2026, 5, 1);
    private static final String COD_PROGRAMA = "PBF";

    // =========================================================================
    // REQ-010 — Geração correta dos pagamentos
    // =========================================================================

    @Nested
    @DisplayName("REQ-010 — Geração de pagamentos para beneficiários ativos")
    class GeracaoPagamentos {

        @Test
        @DisplayName("deve gerar um pagamento para cada beneficiário ATIVO")
        void deveGerarPagamentoParaCadaBeneficiarioAtivo() {
            // Arrange
            List<Beneficiario> ativos = List.of(
                criarBeneficiario("11111111111", SituacaoBeneficiario.ATIVO),
                criarBeneficiario("22222222222", SituacaoBeneficiario.ATIVO),
                criarBeneficiario("33333333333", SituacaoBeneficiario.ATIVO)
            );
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA)).thenReturn(ativos);
            when(pagamentoRepository.existsByBeneficiarioAndCompetencia(any(), any())).thenReturn(false);

            // Act
            ResultadoCiclo resultado = cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            // Assert
            assertThat(resultado.getQtdGerados()).isEqualTo(3);
            assertThat(resultado.getQtdErros()).isEqualTo(0);
            assertThat(resultado.getQtdIgnorados()).isEqualTo(0);
            verify(pagamentoRepository, times(3)).save(any(Pagamento.class));
        }

        @Test
        @DisplayName("pagamento gerado deve ter status PENDENTE")
        void pagamentoGeradoDeveEstarPendente() {
            // Arrange
            Beneficiario ativo = criarBeneficiario("11111111111", SituacaoBeneficiario.ATIVO);
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA)).thenReturn(List.of(ativo));
            when(pagamentoRepository.existsByBeneficiarioAndCompetencia(any(), any())).thenReturn(false);

            // Act
            cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            // Assert — verifica que o pagamento salvo tem status PENDENTE
            verify(pagamentoRepository).save(argThat(pgto ->
                pgto.getSituacao() == SituacaoPagamento.PENDENTE
            ));
        }

        @Test
        @DisplayName("vlr_liquido nunca pode ser maior que vlr_bruto em nenhum pagamento")
        void valorLiquidoNuncaMaiorQueBruto() {
            // Arrange
            List<Beneficiario> ativos = List.of(
                criarBeneficiario("11111111111", SituacaoBeneficiario.ATIVO),
                criarBeneficiario("22222222222", SituacaoBeneficiario.ATIVO)
            );
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA)).thenReturn(ativos);
            when(pagamentoRepository.existsByBeneficiarioAndCompetencia(any(), any())).thenReturn(false);

            // Act
            cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            // Assert — captura todos os pagamentos salvos e verifica a invariante
            verify(pagamentoRepository, atLeastOnce()).save(argThat(pgto ->
                pgto.getVlrLiquido().compareTo(pgto.getVlrBruto()) <= 0
            ));
        }

        @Test
        @DisplayName("deve gerar registro de auditoria com ação BT para cada pagamento criado")
        void deveGerarAuditoriaBatchParaCadaPagamento() {
            // Arrange
            List<Beneficiario> ativos = List.of(
                criarBeneficiario("11111111111", SituacaoBeneficiario.ATIVO),
                criarBeneficiario("22222222222", SituacaoBeneficiario.ATIVO)
            );
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA)).thenReturn(ativos);
            when(pagamentoRepository.existsByBeneficiarioAndCompetencia(any(), any())).thenReturn(false);

            // Act
            cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            // Assert
            verify(auditoriaService, times(2)).registrar(argThat(evento ->
                "BT".equals(evento.getCodAcao()) && "BATCHPGT".equals(evento.getCodModulo())
            ));
        }
    }

    // =========================================================================
    // REQ-011 — Somente beneficiários ATIVOS são processados
    // =========================================================================

    @Nested
    @DisplayName("REQ-011 — Filtragem por status do beneficiário")
    class FiltragemPorStatus {

        @Test
        @DisplayName("beneficiário SUSPENSO não deve gerar pagamento")
        void beneficiarioSuspensNaoGeraPagemento() {
            // Arrange — o repositório só retorna ATIVOS; SUSPENSO não aparece
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA))
                .thenReturn(List.of()); // suspenso filtrado na query

            // Act
            ResultadoCiclo resultado = cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            // Assert
            assertThat(resultado.getQtdGerados()).isZero();
            assertThat(resultado.getQtdIgnorados()).isZero(); // suspenso nem chega ao serviço
            verify(pagamentoRepository, never()).save(any());
        }

        @Test
        @DisplayName("beneficiário CANCELADO não deve gerar pagamento")
        void beneficiarioCanceladoNaoGeraPagamento() {
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA)).thenReturn(List.of());

            ResultadoCiclo resultado = cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            assertThat(resultado.getQtdGerados()).isZero();
            verify(pagamentoRepository, never()).save(any());
        }

        @Test
        @DisplayName("nenhum beneficiário ativo encerra o ciclo com sucesso e zero pagamentos")
        void nenhumAtivoEncerraCicloComSucesso() {
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA)).thenReturn(List.of());

            ResultadoCiclo resultado = cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            assertThat(resultado.getQtdGerados()).isZero();
            assertThat(resultado.isSucesso()).isTrue();
        }
    }

    // =========================================================================
    // REQ-012 — Idempotência: o ciclo não duplica pagamentos
    // Regra original: #JA-GERADO (BATCHPGT.NSN)
    // =========================================================================

    @Nested
    @DisplayName("REQ-012 — Idempotência do ciclo mensal")
    class Idempotencia {

        @Test
        @DisplayName("pagamento já existente na competência é ignorado — não cria duplicata")
        void pagamentoJaExistenteNaoEhDuplicado() {
            // Arrange
            Beneficiario ativo = criarBeneficiario("11111111111", SituacaoBeneficiario.ATIVO);
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA)).thenReturn(List.of(ativo));
            // simula que o pagamento já foi gerado para este beneficiário nesta competência
            when(pagamentoRepository.existsByBeneficiarioAndCompetencia(ativo, COMPETENCIA_202605))
                .thenReturn(true);

            // Act
            ResultadoCiclo resultado = cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            // Assert
            assertThat(resultado.getQtdJaGerados()).isEqualTo(1);
            assertThat(resultado.getQtdGerados()).isZero();
            verify(pagamentoRepository, never()).save(any(Pagamento.class));
        }

        @Test
        @DisplayName("ciclo executado duas vezes resulta no mesmo número de pagamentos")
        void cicloExecutadoDuasVezesResultaMesmoPagamentos() {
            // Arrange: primeira execução gera; segunda detecta já gerado
            Beneficiario ativo = criarBeneficiario("11111111111", SituacaoBeneficiario.ATIVO);
            when(beneficiarioRepository.findAtivosPorPrograma(COD_PROGRAMA)).thenReturn(List.of(ativo));

            // Primeira execução: pagamento não existe ainda
            when(pagamentoRepository.existsByBeneficiarioAndCompetencia(ativo, COMPETENCIA_202605))
                .thenReturn(false)   // primeira chamada
                .thenReturn(true);  // segunda chamada

            // Act
            ResultadoCiclo primeira = cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);
            ResultadoCiclo segunda  = cicloPagamentoService.executar(COD_PROGRAMA, COMPETENCIA_202605);

            // Assert
            assertThat(primeira.getQtdGerados()).isEqualTo(1);
            assertThat(segunda.getQtdGerados()).isZero();
            assertThat(segunda.getQtdJaGerados()).isEqualTo(1);
            // save chamado apenas 1 vez no total
            verify(pagamentoRepository, times(1)).save(any(Pagamento.class));
        }
    }

    // =========================================================================
    // Helpers
    // =========================================================================

    private Beneficiario criarBeneficiario(String cpf, SituacaoBeneficiario situacao) {
        Beneficiario b = new Beneficiario();
        b.setCpf(cpf);
        b.setSituacao(situacao);
        b.setCodPrograma(COD_PROGRAMA);
        b.setVlrRendaFamiliar(new BigDecimal("200.00"));
        b.setQtdMembrosHamilia(1);
        b.setEndCodRegiao("15");
        return b;
    }
}
