import type { ReactNode } from 'react';

interface PaymentCycleLayoutProps {
  title: string;
  children: ReactNode;
}

export function PaymentCycleLayout({ title, children }: PaymentCycleLayoutProps) {
  return (
    <main className="mx-auto max-w-5xl p-6">
      <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
      <section className="mt-6">{children}</section>
    </main>
  );
}
