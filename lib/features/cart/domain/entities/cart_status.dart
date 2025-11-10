enum CartStatus {
  pending,
  awaitingPayment,
  paymentSubmitted,
  paymentRejected,
  completed,
  cancelled,
}

extension CartStatusX on CartStatus {
  String get value {
    switch (this) {
      case CartStatus.pending:
        return 'pending';
      case CartStatus.awaitingPayment:
        return 'awaiting_payment';
      case CartStatus.paymentSubmitted:
        return 'payment_submitted';
      case CartStatus.paymentRejected:
        return 'payment_rejected';
      case CartStatus.completed:
        return 'completed';
      case CartStatus.cancelled:
        return 'cancelled';
    }
  }

  bool get isFinal =>
      this == CartStatus.completed ||
      this == CartStatus.cancelled ||
      this == CartStatus.paymentRejected;

  static CartStatus fromValue(String value) {
    switch (value) {
      case 'pending':
        return CartStatus.pending;
      case 'awaiting_payment':
        return CartStatus.awaitingPayment;
      case 'payment_submitted':
        return CartStatus.paymentSubmitted;
      case 'payment_rejected':
        return CartStatus.paymentRejected;
      case 'completed':
        return CartStatus.completed;
      case 'cancelled':
        return CartStatus.cancelled;
      default:
        return CartStatus.pending;
    }
  }
}








