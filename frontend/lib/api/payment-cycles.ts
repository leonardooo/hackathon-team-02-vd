export interface GeneratePaymentCycleRequest {
  competence: string;
  initiatedBy: string;
  dryRun?: boolean;
}

export interface PaymentCycleSummary {
  id: string;
  competence: string;
  status: 'GENERATING' | 'GENERATED' | 'FAILED' | 'CANCELLED';
  includedCount: number;
  excludedCount: number;
  createdAt: string;
  generatedAt?: string;
}

export interface PaymentCycleDetail extends PaymentCycleSummary {
  generationSummary?: string;
  initiatedBy: string;
}

export interface PaymentCycleEntry {
  beneficiaryId: string;
  beneficiaryCpf: string;
  programCode: string;
  inclusionStatus: 'INCLUDED' | 'EXCLUDED';
  exclusionReasonCode?: string;
  exclusionReasonText?: string;
  grossAmount?: number;
  discountAmount?: number;
  netAmount?: number;
}

export interface ApiError {
  code: string;
  message: string;
}

const API_BASE = '/api/v1/payment-cycles';

export async function generatePaymentCycle(payload: GeneratePaymentCycleRequest): Promise<PaymentCycleSummary> {
  const response = await fetch(API_BASE, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const body = (await response.json().catch(() => null)) as ApiError | null;
    throw new Error(body?.message ?? 'Failed to generate payment cycle');
  }

  return (await response.json()) as PaymentCycleSummary;
}

export async function listPaymentCycles(competence?: string): Promise<PaymentCycleSummary[]> {
  const url = competence ? `${API_BASE}?competence=${encodeURIComponent(competence)}` : API_BASE;
  const response = await fetch(url, { cache: 'no-store' });
  if (!response.ok) {
    throw new Error('Failed to list payment cycles');
  }
  return (await response.json()) as PaymentCycleSummary[];
}

export async function getPaymentCycle(cycleId: string): Promise<PaymentCycleDetail> {
  const response = await fetch(`${API_BASE}/${cycleId}`, { cache: 'no-store' });
  if (!response.ok) {
    throw new Error('Failed to fetch payment cycle');
  }
  return (await response.json()) as PaymentCycleDetail;
}

export async function listPaymentCycleEntries(cycleId: string, inclusionStatus?: 'INCLUDED' | 'EXCLUDED'): Promise<PaymentCycleEntry[]> {
  const query = inclusionStatus ? `?inclusionStatus=${inclusionStatus}` : '';
  const response = await fetch(`${API_BASE}/${cycleId}/entries${query}`, { cache: 'no-store' });
  if (!response.ok) {
    throw new Error('Failed to fetch payment cycle entries');
  }
  return (await response.json()) as PaymentCycleEntry[];
}
