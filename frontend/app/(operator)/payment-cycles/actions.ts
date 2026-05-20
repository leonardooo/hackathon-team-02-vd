'use server';

import { generatePaymentCycle } from '@/lib/api/payment-cycles';
import { revalidatePath } from 'next/cache';

export async function generateCycleAction(formData: FormData) {
  const competence = formData.get('competence') as string;
  const initiatedBy = formData.get('initiatedBy') as string;

  if (!competence || !initiatedBy) {
    return { error: 'Competence and operator are required' };
  }

  if (!/^[0-9]{6}$/.test(competence)) {
    return { error: 'Competence must be YYYYMM format (6 digits)' };
  }

  try {
    const result = await generatePaymentCycle({ competence, initiatedBy });
    revalidatePath('/payment-cycles');
    return { success: `Cycle ${result.competence} generated with ${result.includedCount} included` };
  } catch (error) {
    return { error: error instanceof Error ? error.message : 'Unknown error' };
  }
}
