import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { PaymentCycleLayout } from './payment-cycle-layout';

describe('PaymentCycleLayout', () => {
  it('should render the title', () => {
    render(
      <PaymentCycleLayout title="Payment Cycles">
        <p>Content</p>
      </PaymentCycleLayout>
    );

    expect(screen.getByText('Payment Cycles')).toBeInTheDocument();
  });

  it('should render children content', () => {
    render(
      <PaymentCycleLayout title="Test Title">
        <p>Child content here</p>
      </PaymentCycleLayout>
    );

    expect(screen.getByText('Child content here')).toBeInTheDocument();
  });

  it('should use proper heading element', () => {
    render(
      <PaymentCycleLayout title="Heading Test">
        <p>Body</p>
      </PaymentCycleLayout>
    );

    const heading = screen.getByRole('heading', { level: 1 });
    expect(heading).toHaveTextContent('Heading Test');
  });
});
