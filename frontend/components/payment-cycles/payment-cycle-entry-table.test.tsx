import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { PaymentCycleEntryTable } from './payment-cycle-entry-table';
import type { PaymentCycleEntry } from '../../lib/api/payment-cycles';

describe('PaymentCycleEntryTable', () => {
  const mockEntries: PaymentCycleEntry[] = [
    {
      beneficiaryId: 'ben-1',
      beneficiaryCpf: '529.982.247-25',
      programCode: 'BPC',
      inclusionStatus: 'INCLUDED',
      grossAmount: 1412.0,
      discountAmount: 0.0,
      netAmount: 1412.0,
    },
    {
      beneficiaryId: 'ben-2',
      beneficiaryCpf: '111.222.333-44',
      programCode: 'PBF',
      inclusionStatus: 'EXCLUDED',
      exclusionReasonCode: 'INACTIVE',
      exclusionReasonText: 'Beneficiary is inactive',
    },
  ];

  it('should render table headers', () => {
    render(<PaymentCycleEntryTable entries={mockEntries} />);

    expect(screen.getByText('CPF')).toBeInTheDocument();
    expect(screen.getByText('Program')).toBeInTheDocument();
    expect(screen.getByText('Status')).toBeInTheDocument();
    expect(screen.getByText('Reason')).toBeInTheDocument();
  });

  it('should render all entries', () => {
    render(<PaymentCycleEntryTable entries={mockEntries} />);

    expect(screen.getByText('529.982.247-25')).toBeInTheDocument();
    expect(screen.getByText('111.222.333-44')).toBeInTheDocument();
  });

  it('should display exclusion reason for excluded entries', () => {
    render(<PaymentCycleEntryTable entries={mockEntries} />);

    expect(screen.getByText('Beneficiary is inactive')).toBeInTheDocument();
  });

  it('should show dash when no exclusion reason', () => {
    render(<PaymentCycleEntryTable entries={mockEntries} />);

    const cells = screen.getAllByRole('cell');
    const reasonCells = cells.filter((cell) => cell.textContent === '-');
    expect(reasonCells.length).toBeGreaterThanOrEqual(1);
  });

  it('should display inclusion status', () => {
    render(<PaymentCycleEntryTable entries={mockEntries} />);

    expect(screen.getByText('INCLUDED')).toBeInTheDocument();
    expect(screen.getByText('EXCLUDED')).toBeInTheDocument();
  });
});
