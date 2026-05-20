'use client';

import { useState } from 'react';
import { generateCycleAction } from '../../app/(operator)/payment-cycles/actions';

export function PaymentCycleGenerateForm() {
  const [message, setMessage] = useState<string | null>(null);

  async function onSubmit(formData: FormData) {
    setMessage(null);
    const result = await generateCycleAction(formData);
    setMessage(result.error ?? result.success ?? null);
  }

  return (
    <form className="grid gap-4 rounded-xl border p-4" action={onSubmit}>
      <label className="grid gap-1">
        <span className="text-sm font-medium">Competence (YYYYMM)</span>
        <input
          className="rounded border px-3 py-2"
          name="competence"
          pattern="^[0-9]{6}$"
          required
        />
      </label>

      <label className="grid gap-1">
        <span className="text-sm font-medium">Operator</span>
        <input
          className="rounded border px-3 py-2"
          name="initiatedBy"
          defaultValue="operator"
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
