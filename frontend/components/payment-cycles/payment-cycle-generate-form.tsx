'use client';

import { useState } from 'react';
import { generatePaymentCycle } from '../../lib/api/payment-cycles';

export function PaymentCycleGenerateForm() {
  const [competence, setCompetence] = useState('');
  const [initiatedBy, setInitiatedBy] = useState('operator');
  const [message, setMessage] = useState<string | null>(null);

  async function onSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setMessage(null);

    try {
      const result = await generatePaymentCycle({ competence, initiatedBy });
      setMessage(`Cycle ${result.competence} generated with ${result.includedCount} included`);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Unknown error');
    }
  }

  return (
    <form className="grid gap-4 rounded-xl border p-4" onSubmit={onSubmit}>
      <label className="grid gap-1">
        <span className="text-sm font-medium">Competence (YYYYMM)</span>
        <input
          className="rounded border px-3 py-2"
          value={competence}
          onChange={(event) => setCompetence(event.target.value)}
          pattern="^[0-9]{6}$"
          required
        />
      </label>

      <label className="grid gap-1">
        <span className="text-sm font-medium">Operator</span>
        <input
          className="rounded border px-3 py-2"
          value={initiatedBy}
          onChange={(event) => setInitiatedBy(event.target.value)}
          required
        />
      </label>

      <button className="rounded bg-black px-4 py-2 text-white" type="submit">
        Generate cycle
      </button>

      {message ? <p className="text-sm">{message}</p> : null}
    </form>
  );
}
