import { PaymentCycleGenerateForm } from '../../../components/payment-cycles/payment-cycle-generate-form';
import { PaymentCycleLayout } from '../../../components/payment-cycles/payment-cycle-layout';
import { PaymentCycleSummaryList } from '../../../components/payment-cycles/payment-cycle-summary-list';
import { listPaymentCycles } from '../../../lib/api/payment-cycles';

export default async function PaymentCyclesPage() {
  const cycles = await listPaymentCycles();

  return (
    <PaymentCycleLayout title="Payment Cycles">
      <PaymentCycleGenerateForm />
      <section className="mt-6">
        <h2 className="mb-2 text-lg font-medium">Recent cycles</h2>
        <PaymentCycleSummaryList cycles={cycles} />
      </section>
    </PaymentCycleLayout>
  );
}
