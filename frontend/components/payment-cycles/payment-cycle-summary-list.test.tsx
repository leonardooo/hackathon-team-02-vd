import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { PaymentCycleSummaryList } from './payment-cycle-summary-list';
import type { PaymentCycleSummary } from '../../lib/api/payment-cycles';

describe('PaymentCycleSummaryList', () => {
  const mockCycles: PaymentCycleSummary[] = [
    {
      id: 'cycle-1',
      competence: '202605',
      status: 'GENERATED',
      includedCount: 50,
      excludedCount: 5,
      createdAt: '2025-06-01T10:00:00Z',
      generatedAt: '2025-06-01T10:01:00Z',
    },
    {
      id: 'cycle-2',
      competence: '202606',
      status: 'GENERATING',
      includedCount: 0,
      excludedCount: 0,
      createdAt: '2025-06-15T10:00:00Z',
    },
  ];

  it('should render all cycles', () => {
    render(<PaymentCycleSummaryList cycles={mockCycles} />);

    expect(screen.getByText('202605')).toBeInTheDocument();
    expect(screen.getByText('202606')).toBeInTheDocument();
  });

  it('should display status for each cycle', () => {
    render(<PaymentCycleSummaryList cycles={mockCycles} />);

    expect(screen.getByText('Status: GENERATED')).toBeInTheDocument();
    expect(screen.getByText('Status: GENERATING')).toBeInTheDocument();
  });

  it('should display included and excluded counts', () => {
    render(<PaymentCycleSummaryList cycles={mockCycles} />);

    expect(screen.getByText('Included: 50 | Excluded: 5')).toBeInTheDocument();
  });

  it('should show message when no cycles exist', () => {
    render(<PaymentCycleSummaryList cycles={[]} />);

    expect(screen.getByText('No cycles found.')).toBeInTheDocument();
  });
});
