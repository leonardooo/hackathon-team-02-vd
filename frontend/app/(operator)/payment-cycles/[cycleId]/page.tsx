import { PaymentCycleEntryTable } from '../../../../components/payment-cycles/payment-cycle-entry-table';
import { getPaymentCycle, listPaymentCycleEntries } from '../../../../lib/api/payment-cycles';

interface PaymentCycleDetailPageProps {
  params: Promise<{ cycleId: string }>;
}

export default async function PaymentCycleDetailPage({ params }: PaymentCycleDetailPageProps) {
  const { cycleId } = await params;
  const cycle = await getPaymentCycle(cycleId);
  const entries = await listPaymentCycleEntries(cycleId);

  return (
    <main className="mx-auto max-w-6xl p-6">
      <h1 className="text-2xl font-semibold">Cycle {cycle.competence}</h1>
      <p className="mt-2 text-sm">Included: {cycle.includedCount} | Excluded: {cycle.excludedCount}</p>
      <section className="mt-6">
        <PaymentCycleEntryTable entries={entries} />
      </section>
    </main>
  );
}
