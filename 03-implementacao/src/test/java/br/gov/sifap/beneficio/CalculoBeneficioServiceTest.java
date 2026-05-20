package br.gov.sifap.beneficio;

import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.math.BigDecimal;
import java.math.RoundingMode;

import static org.assertj.core.api.Assertions.*;

/**
 * Testes unitários para as regras de cálculo do benefício mensal.
 *
 * Rastreabilidade:
 *   REQ-001 — Cálculo base por faixa de renda (CALCBENF.NSN linhas 120-135)
 *   REQ-002 — Fator regional por UF        (CALCBENF.NSN linhas 88-118)
 *   REQ-003 — Fator familiar por dependentes (CALCBENF.NSN linhas 200-218)
 *
 * Regras extraídas do Natural CALCBENF.NSN (legado SIFAP 1997-2013).
 * QA PAR 4 — 2026-05-20
 */
@DisplayName("REQ-001/002/003 — Cálculo do valor do benefício mensal")
class CalculoBeneficioServiceTest {

    // Valor base do programa PBF usado nos testes
    private static final BigDecimal VLR_BASE = new BigDecimal("600.00");

    // Instância do serviço a ser testado (a ser implementado pelo PAR 3)
    private CalculoBeneficioService service;

    @BeforeEach
    void setUp() {
        service = new CalculoBeneficioService();
    }

    // =========================================================================
    // REQ-001 — Faixas de renda (CALCBENF.NSN linhas 120-135)
    // =========================================================================

    @Nested
    @DisplayName("REQ-001 — Fator de faixa de renda")
    class FatorFaixaRenda {

        @ParameterizedTest(name = "renda={0} → fator={1}")
        @CsvSource({
            "0.00,    1.0000",   // faixa 1: até 300,00
            "200.00,  1.0000",   // faixa 1: dentro
            "300.00,  1.0000",   // faixa 1: limite exato
            "300.01,  0.8500",   // faixa 2: logo acima do limite
            "600.00,  0.8500",   // faixa 2: limite exato
            "600.01,  0.7000",   // faixa 3: logo acima
            "1000.00, 0.7000",   // faixa 3: limite exato
            "1000.01, 0.5500",   // faixa 4: logo acima
            "1500.00, 0.5500",   // faixa 4: limite exato
            "1500.01, 0.4000",   // faixa 5: acima do teto
            "9999.99, 0.4000"    // faixa 5: valor máximo
        })
        @DisplayName("deve retornar o fator correto para cada faixa de renda")
        void deveCalcularFatorFaixaRendaCorretamente(String rendaStr, String fatorEsperadoStr) {
            BigDecimal renda = new BigDecimal(rendaStr);
            BigDecimal fatorEsperado = new BigDecimal(fatorEsperadoStr);

            BigDecimal fatorCalculado = service.calcularFatorFaixaRenda(renda);

            assertThat(fatorCalculado)
                .as("Fator de faixa para renda %s", rendaStr)
                .isEqualByComparingTo(fatorEsperado);
        }

        @Test
        @DisplayName("renda negativa deve lançar exceção de negócio")
        void rendaNegativaDeveLancarExcecao() {
            assertThatThrownBy(() -> service.calcularFatorFaixaRenda(new BigDecimal("-1.00")))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("renda");
        }
    }

    // =========================================================================
    // REQ-002 — Fator regional por código de região (CALCBENF.NSN linhas 88-118)
    // Tabela #TAB-REG de 27 posições — extraída literalmente do Natural legado
    // =========================================================================

    @Nested
    @DisplayName("REQ-002 — Fator regional por código de região")
    class FatorRegional {

        @ParameterizedTest(name = "cod_regiao={0} (estado={1}) → fator={2}")
        @CsvSource({
            "1,  AC, 1.3500",
            "2,  AM, 1.3200",
            "6,  MA, 1.4000",   // maior fator — Nordeste
            "10, PE, 1.3600",
            "11, SP, 1.1000",
            "15, REF, 1.0000",  // referência — fator neutro
            "16, PR, 1.0500",
            "18, RS, 1.0300"    // menor fator — Sul
        })
        @DisplayName("deve retornar o fator regional correto para cada estado")
        void deveRetornarFatorRegionalCorreto(int codRegiao, String estado, String fatorEsperadoStr) {
            BigDecimal fatorEsperado = new BigDecimal(fatorEsperadoStr);

            BigDecimal fatorCalculado = service.calcularFatorRegional(codRegiao);

            assertThat(fatorCalculado)
                .as("Fator regional para cod_regiao=%d (%s)", codRegiao, estado)
                .isEqualByComparingTo(fatorEsperado);
        }

        @ParameterizedTest(name = "cod_regiao={0} → fator padrão 1.0000")
        @CsvSource({"0", "26", "27", "99", "999"})
        @DisplayName("código de região fora do intervalo 1-25 retorna fator 1.0000 (padrão legado)")
        void codigoRegiaoForaDoIntervaloRetornaFatorPadrao(int codRegiao) {
            BigDecimal fatorCalculado = service.calcularFatorRegional(codRegiao);

            assertThat(fatorCalculado)
                .as("cod_regiao=%d deve retornar fator padrão 1.0000", codRegiao)
                .isEqualByComparingTo(BigDecimal.ONE);
        }
    }

    // =========================================================================
    // REQ-003 — Fator familiar por número de dependentes (CALCBENF.NSN linhas 200-218)
    //   0 deps       → 1.0000
    //   1-2 deps     → 1.0000 + (num_dep * 0.0500)
    //   3-4 deps     → 1.1000 + ((num_dep - 2) * 0.0300)
    //   5+ deps      → 1.1600 + ((num_dep - 4) * 0.0200)
    // =========================================================================

    @Nested
    @DisplayName("REQ-003 — Fator familiar por número de dependentes")
    class FatorFamiliar {

        @ParameterizedTest(name = "num_dependentes={0} → fator={1}")
        @CsvSource({
            "0,  1.0000",   // sem dependentes
            "1,  1.0500",   // 1.0000 + (1 * 0.0500)
            "2,  1.1000",   // 1.0000 + (2 * 0.0500)
            "3,  1.1300",   // 1.1000 + ((3-2) * 0.0300)
            "4,  1.1600",   // 1.1000 + ((4-2) * 0.0300)
            "5,  1.1800",   // 1.1600 + ((5-4) * 0.0200)
            "10, 1.2800"    // 1.1600 + ((10-4) * 0.0200)
        })
        @DisplayName("deve calcular o fator familiar correto por número de dependentes ativos")
        void deveCalcularFatorFamiliarCorreto(int numDependentes, String fatorEsperadoStr) {
            BigDecimal fatorEsperado = new BigDecimal(fatorEsperadoStr);

            BigDecimal fatorCalculado = service.calcularFatorFamiliar(numDependentes);

            assertThat(fatorCalculado)
                .as("Fator familiar para %d dependentes", numDependentes)
                .isEqualByComparingTo(fatorEsperado);
        }

        @Test
        @DisplayName("número negativo de dependentes deve lançar exceção")
        void numDependentesNegativoDeveLancarExcecao() {
            assertThatThrownBy(() -> service.calcularFatorFamiliar(-1))
                .isInstanceOf(IllegalArgumentException.class);
        }
    }

    // =========================================================================
    // REQ-001 — Cálculo completo integrado (faixa × regional × familiar)
    // =========================================================================

    @Nested
    @DisplayName("REQ-001/002/003 — Cálculo completo do benefício")
    class CalculoCompleto {

        @Test
        @DisplayName("beneficiário sem dependentes, renda baixa, região neutra recebe valor base integral")
        void semDependentesRendaBaixaRegiaoNeutra() {
            // vlr_base=600 × faixa(200)=1.0000 × regional(15)=1.0000 × familiar(0)=1.0000
            BigDecimal vlrBruto = service.calcularValorBruto(VLR_BASE,
                new BigDecimal("200.00"), 15, 0);

            assertThat(vlrBruto).isEqualByComparingTo(new BigDecimal("600.00"));
        }

        @Test
        @DisplayName("fator regional MA (1.4000) eleva o benefício corretamente")
        void fatorRegionalNordesteElevaValor() {
            // vlr_base=600 × faixa(200)=1.0000 × regional(6)=1.4000 × familiar(0)=1.0000
            BigDecimal vlrBruto = service.calcularValorBruto(VLR_BASE,
                new BigDecimal("200.00"), 6, 0);

            assertThat(vlrBruto).isEqualByComparingTo(new BigDecimal("840.00"));
        }

        @Test
        @DisplayName("2 dependentes elevam o benefício em 10%")
        void doisDependentesElevamValor() {
            // vlr_base=600 × faixa(200)=1.0000 × regional(15)=1.0000 × familiar(2)=1.1000
            BigDecimal vlrBruto = service.calcularValorBruto(VLR_BASE,
                new BigDecimal("200.00"), 15, 2);

            assertThat(vlrBruto).isEqualByComparingTo(new BigDecimal("660.00"));
        }

        @Test
        @DisplayName("faixa de renda alta reduz o benefício para 40% do valor base")
        void rendaAltaReduzBeneficioA40Porcento() {
            // vlr_base=600 × faixa(2000)=0.4000 × regional(15)=1.0000 × familiar(0)=1.0000
            BigDecimal vlrBruto = service.calcularValorBruto(VLR_BASE,
                new BigDecimal("2000.00"), 15, 0);

            assertThat(vlrBruto).isEqualByComparingTo(new BigDecimal("240.00"));
        }

        @Test
        @DisplayName("valor líquido nunca pode ser negativo")
        void valorLiquidoNuncaNegativo() {
            BigDecimal vlrBruto = new BigDecimal("600.00");
            BigDecimal descontoAbusivo = new BigDecimal("700.00");

            assertThatThrownBy(() -> service.calcularValorLiquido(vlrBruto, descontoAbusivo))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("desconto");
        }

        @Test
        @DisplayName("valor líquido = bruto quando não há descontos")
        void valorLiquidoIgualBrutoSemDescontos() {
            BigDecimal vlrBruto = new BigDecimal("600.00");
            BigDecimal vlrLiquido = service.calcularValorLiquido(vlrBruto, BigDecimal.ZERO);

            assertThat(vlrLiquido).isEqualByComparingTo(vlrBruto);
        }

        @Test
        @DisplayName("arredondamento deve usar HALF_UP com 2 casas decimais")
        void arredondamentoDeveSerHalfUp() {
            // 600 * 0.8500 = 510,00 — exato, sem arredondamento
            BigDecimal vlrBruto = service.calcularValorBruto(VLR_BASE,
                new BigDecimal("400.00"), 15, 0);

            assertThat(vlrBruto.scale()).isEqualTo(2);
            assertThat(vlrBruto).isEqualByComparingTo(new BigDecimal("510.00"));
        }
    }
}
