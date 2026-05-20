import type { PaymentCycleEntry } from '../../lib/api/payment-cycles';

interface PaymentCycleEntryTableProps {
  entries: PaymentCycleEntry[];
}

export function PaymentCycleEntryTable({ entries }: PaymentCycleEntryTableProps) {
  return (
    <div className="overflow-x-auto rounded border">
      <table className="min-w-full text-sm">
        <thead>
          <tr className="bg-neutral-100 text-left">
            <th className="px-3 py-2">CPF</th>
            <th className="px-3 py-2">Program</th>
            <th className="px-3 py-2">Status</th>
            <th className="px-3 py-2">Reason</th>
          </tr>
        </thead>
        <tbody>
          {entries.map((entry) => (
            <tr className="border-t" key={`${entry.beneficiaryId}-${entry.inclusionStatus}`}>
              <td className="px-3 py-2">{entry.beneficiaryCpf}</td>
              <td className="px-3 py-2">{entry.programCode}</td>
              <td className="px-3 py-2">{entry.inclusionStatus}</td>
              <td className="px-3 py-2">{entry.exclusionReasonText ?? '-'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
