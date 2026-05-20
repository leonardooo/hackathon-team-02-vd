import type { PaymentCycleSummary } from '../../lib/api/payment-cycles';

interface PaymentCycleSummaryListProps {
  cycles: PaymentCycleSummary[];
}

export function PaymentCycleSummaryList({ cycles }: PaymentCycleSummaryListProps) {
  if (cycles.length === 0) {
    return <p className="text-sm text-neutral-600">No cycles found.</p>;
  }

  return (
    <ul className="grid gap-2">
      {cycles.map((cycle) => (
        <li className="rounded border p-3" key={cycle.id}>
          <p className="font-medium">{cycle.competence}</p>
          <p className="text-sm">Status: {cycle.status}</p>
          <p className="text-sm">Included: {cycle.includedCount} | Excluded: {cycle.excludedCount}</p>
        </li>
      ))}
    </ul>
  );
}
