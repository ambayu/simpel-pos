import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models.dart';

class ReceiptPrinter {
  static Future<void> printReceipt(SaleRecord transaction) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.roll57.copyWith(
      marginLeft: 8,
      marginRight: 8,
      marginTop: 10,
      marginBottom: 10,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  'SIMPEL POS',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'Struk Pembayaran',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 8),
              _row('No', transaction.id),
              _row('Tanggal', _formatDateTime(transaction.createdAt)),
              _row('Pesanan', transaction.orderLabel),
              _row('Kasir', transaction.cashier),
              _row('Bayar', transaction.paymentMethod),
              pw.Divider(thickness: 0.5),
              ...transaction.items.map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.productName,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      _row(
                        '${item.quantity} x ${rupiah(item.unitPrice)}',
                        rupiah(item.total),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Divider(thickness: 0.5),
              _row('Subtotal', rupiah(transaction.subtotal)),
              _row('Pajak 10%', rupiah(transaction.tax)),
              pw.SizedBox(height: 4),
              _row(
                'TOTAL',
                rupiah(transaction.total),
                bold: true,
                fontSize: 10,
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Terima kasih',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'struk_${transaction.id}.pdf',
      format: pageFormat,
      onLayout: (_) async => pdf.save(),
    );
  }

  static pw.Widget _row(
    String label,
    String value, {
    bool bold = false,
    double fontSize = 8,
  }) {
    final style = pw.TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.SizedBox(width: 6),
          pw.Text(value, style: style, textAlign: pw.TextAlign.right),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    String two(int input) => input.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}
