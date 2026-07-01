import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juskar/models/category.dart';
import 'package:juskar/models/order.dart' as order_model;
import 'package:juskar/services/firebase_category_service.dart';
import 'package:juskar/services/firebase_order_service.dart';

enum AnalyticsGrouping {
  days,
  weeks,
  months,
  quarters,
  semesters,
  years,
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  AnalyticsGrouping _grouping = AnalyticsGrouping.months;
  DateTimeRange? _selectedRange;
  int? _selectedPointIndex;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedRange = DateTimeRange(
      start: DateTime(today.year - 1, today.month, 1),
      end: DateTime(today.year, today.month, today.day, 23, 59, 59),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analítica'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Category>>(
        stream: FirebaseCategoryService.getCategories(),
        builder: (context, categoriesSnapshot) {
          return StreamBuilder<List<order_model.Order>>(
            stream: FirebaseOrderService.getOrders(),
            builder: (context, ordersSnapshot) {
              if (categoriesSnapshot.hasError || ordersSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar la analítica',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }

              if (categoriesSnapshot.connectionState == ConnectionState.waiting ||
                  ordersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = categoriesSnapshot.data ?? [];
              final orders = ordersSnapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildRangeCard(context),
                  const SizedBox(height: 12),
                  _buildGroupingSelector(),
                  const SizedBox(height: 16),
                  _buildInteractiveChartCard(context, orders),
                  const SizedBox(height: 16),
                  _buildSummary(context, orders),
                  const SizedBox(height: 16),
                  _buildCategoryStats(context, orders, categories),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRangeCard(BuildContext context) {
    final range = _selectedRange!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_outlined, color: Color(0xFF7C7BFF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Intervalo de tiempo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: _pickDateRange,
                child: const Text('Cambiar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatDate(range.start)} - ${_formatDate(range.end)}',
            style: TextStyle(color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupingSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AnalyticsGrouping.values.map((grouping) {
        final selected = _grouping == grouping;
        return ChoiceChip(
          label: Text(_groupingLabel(grouping)),
          selected: selected,
          onSelected: (_) {
            setState(() {
              _grouping = grouping;
              _selectedPointIndex = null;
            });
          },
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: const Color(0xFF7C7BFF),
          backgroundColor: const Color(0xFF2A2A2A),
          side: const BorderSide(color: Color(0xFF404040)),
        );
      }).toList(),
    );
  }

  Widget _buildInteractiveChartCard(BuildContext context, List<order_model.Order> orders) {
    final filteredOrders = _filterOrdersByRange(orders);
    final points = _buildChartPoints(filteredOrders);
    final selectedPoint = _selectedPointIndex == null || _selectedPointIndex! >= points.length
        ? null
        : points[_selectedPointIndex!];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, color: Color(0xFF7C7BFF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ventas interactivas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${filteredOrders.length} pedidos',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (points.isEmpty)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: const Text('No hay datos en este rango', style: TextStyle(color: Colors.white70)),
            )
          else
            SizedBox(
              height: 240,
              child: GestureDetector(
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final width = box.size.width - 48;
                  if (width <= 0) return;
                  final chartLeft = 24.0;
                  final chartRight = 24.0;
                  final chartWidth = box.size.width - chartLeft - chartRight;
                  final dx = localPosition.dx.clamp(chartLeft, box.size.width - chartRight);
                  final relativeX = (dx - chartLeft) / chartWidth;
                  final index = (relativeX * (points.length - 1)).round().clamp(0, points.length - 1);
                  setState(() {
                    _selectedPointIndex = index;
                  });
                },
                child: CustomPaint(
                  painter: _LineChartPainter(
                    points: points,
                    selectedIndex: _selectedPointIndex,
                  ),
                  child: Container(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (selectedPoint != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF404040)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPoint.label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${selectedPoint.value} ventas',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, List<order_model.Order> orders) {
    final filteredOrders = _filterOrdersByRange(orders);
    final totalOrders = filteredOrders.length;
    final completedOrders = filteredOrders.where((order) => order.pedidoCompleto).length;
    final pendingOrders = totalOrders - completedOrders;
    final totalRevenue = filteredOrders.fold<double>(0, (sum, order) => sum + order.pedidoValor);
    final averageTicket = totalOrders == 0 ? 0.0 : totalRevenue / totalOrders;
    final completionRate = totalOrders == 0 ? 0.0 : (completedOrders / totalOrders) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Resumen del rango'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _MetricCard(
              title: 'Pedidos',
              value: totalOrders.toString(),
              icon: Icons.receipt_long_outlined,
            ),
            _MetricCard(
              title: 'Ingresos',
              value: _formatMoney(totalRevenue),
              icon: Icons.attach_money_rounded,
            ),
            _MetricCard(
              title: 'Ticket promedio',
              value: _formatMoney(averageTicket),
              icon: Icons.trending_up,
            ),
            _MetricCard(
              title: 'Completados',
              value: '${completionRate.toStringAsFixed(1)}%',
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SmallStatCard(
                title: 'Pendientes',
                value: pendingOrders.toString(),
                color: Colors.orange,
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallStatCard(
                title: 'Completados',
                value: completedOrders.toString(),
                color: Colors.green,
                icon: Icons.done_all,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryStats(BuildContext context, List<order_model.Order> orders, List<Category> categories) {
    final categoryById = {for (final category in categories) category.id: category};
    final filteredOrders = _filterOrdersByRange(orders);
    final counts = <String, int>{};
    final colors = <String, Color>{};

    for (final order in filteredOrders) {
      final category = categoryById[order.pedidoCategoria];
      final label = category?.nombre ?? order.pedidoCategoria;
      counts[label] = (counts[label] ?? 0) + 1;
      colors[label] = category?.color ?? const Color(0xFF7C7BFF);
    }

    final items = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Ventas por categoría'),
        if (items.isEmpty)
          Container(
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No hay ventas por categoría en este rango',
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          Column(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[item.key] ?? const Color(0xFF7C7BFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.key,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      item.value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  List<order_model.Order> _filterOrdersByRange(List<order_model.Order> orders) {
    final range = _selectedRange!;
    return orders.where((order) {
      final date = order.pedidoFecha;
      return !date.isBefore(DateTime(range.start.year, range.start.month, range.start.day)) &&
          !date.isAfter(DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59));
    }).toList();
  }

  List<_ChartPoint> _buildChartPoints(List<order_model.Order> orders) {
    final groups = <String, _ChartPointBuilder>{};

    for (final order in orders) {
      final key = _groupKey(order.pedidoFecha);
      final label = _groupLabel(order.pedidoFecha);
      groups.putIfAbsent(key, () => _ChartPointBuilder(label: label));
      groups[key]!.count += 1;
    }

    final entries = groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map((entry) => _ChartPoint(label: entry.value.label, value: entry.value.count.toDouble()))
        .toList();
  }

  String _groupKey(DateTime date) {
    switch (_grouping) {
      case AnalyticsGrouping.days:
        return DateFormat('yyyy-MM-dd').format(date);
      case AnalyticsGrouping.weeks:
        return '${date.year}-W${_weekOfYear(date).toString().padLeft(2, '0')}';
      case AnalyticsGrouping.months:
        return DateFormat('yyyy-MM').format(date);
      case AnalyticsGrouping.quarters:
        return '${date.year}-Q${((date.month - 1) ~/ 3) + 1}';
      case AnalyticsGrouping.semesters:
        return '${date.year}-S${date.month <= 6 ? 1 : 2}';
      case AnalyticsGrouping.years:
        return '${date.year}';
    }
  }

  String _groupLabel(DateTime date) {
    switch (_grouping) {
      case AnalyticsGrouping.days:
        return DateFormat('dd/MM').format(date);
      case AnalyticsGrouping.weeks:
        return 'Sem ${_weekOfYear(date)}';
      case AnalyticsGrouping.months:
        return DateFormat('yyyy-MM').format(date);
      case AnalyticsGrouping.quarters:
        return 'T${((date.month - 1) ~/ 3) + 1} ${date.year}';
      case AnalyticsGrouping.semesters:
        return 'S${date.month <= 6 ? 1 : 2} ${date.year}';
      case AnalyticsGrouping.years:
        return date.year.toString();
    }
  }

  int _weekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return ((date.difference(startOfYear).inDays) / 7).floor() + 1;
  }

  String _groupingLabel(AnalyticsGrouping grouping) {
    switch (grouping) {
      case AnalyticsGrouping.days:
        return 'Días';
      case AnalyticsGrouping.weeks:
        return 'Semanas';
      case AnalyticsGrouping.months:
        return 'Meses';
      case AnalyticsGrouping.quarters:
        return 'Trimestres';
      case AnalyticsGrouping.semesters:
        return 'Semestres';
      case AnalyticsGrouping.years:
        return 'Años';
    }
  }

  String _formatMoney(double value) {
    return _currencyFormat.format(value.round());
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C7BFF),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
        _selectedPointIndex = null;
      });
    }
  }
}

class _LineChartPainter extends CustomPainter {
  final List<_ChartPoint> points;
  final int? selectedIndex;

  _LineChartPainter({required this.points, required this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const paddingLeft = 24.0;
    const paddingRight = 24.0;
    const paddingTop = 24.0;
    const paddingBottom = 40.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;
    final maxValue = points.map((point) => point.value).reduce((a, b) => a > b ? a : b);
    final minValue = 0.0;

    final backgroundPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = const Color(0xFF404040)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF7C7BFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x667C7BFF), Color(0x001E1E1E)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final dotPaint = Paint()..color = const Color(0xFFB7B7FF);
    final selectedDotPaint = Paint()..color = Colors.white;

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, chartHeight),
      const Radius.circular(16),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    for (int i = 0; i < 4; i++) {
      final y = paddingTop + (chartHeight / 3) * i;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);
    }

    final pointPositions = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final dx = points.length == 1
          ? paddingLeft + chartWidth / 2
          : paddingLeft + (chartWidth * i / (points.length - 1));
      final normalized = maxValue == minValue ? 0.0 : (point.value - minValue) / (maxValue - minValue);
      final dy = paddingTop + chartHeight - (normalized * chartHeight);
      pointPositions.add(Offset(dx, dy));
    }

    final areaPath = Path()..moveTo(pointPositions.first.dx, size.height - paddingBottom);
    for (final position in pointPositions) {
      areaPath.lineTo(position.dx, position.dy);
    }
    areaPath.lineTo(pointPositions.last.dx, size.height - paddingBottom);
    areaPath.close();
    canvas.drawPath(areaPath, fillPaint);

    final linePath = Path()..moveTo(pointPositions.first.dx, pointPositions.first.dy);
    for (final position in pointPositions.skip(1)) {
      linePath.lineTo(position.dx, position.dy);
    }
    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < pointPositions.length; i++) {
      final position = pointPositions[i];
      final isSelected = selectedIndex == i;
      canvas.drawCircle(position, isSelected ? 6 : 4, isSelected ? selectedDotPaint : dotPaint);
    }

    final labelStyle = TextStyle(color: Colors.grey[300], fontSize: 11);
    for (int i = 0; i < points.length; i++) {
      final position = pointPositions[i];
      final label = points[i].label;
      final span = TextSpan(text: label, style: labelStyle);
      final painter = TextPainter(text: span, textDirection: ui.TextDirection.ltr)
        ..layout(maxWidth: 64);
      final dx = position.dx - painter.width / 2;
      final dy = size.height - paddingBottom + 8;
      painter.paint(canvas, Offset(dx.clamp(0, size.width - painter.width), dy));

      if (selectedIndex == i) {
        final valuePainter = TextPainter(
          text: TextSpan(
            text: points[i].value.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        valuePainter.paint(canvas, Offset(position.dx - valuePainter.width / 2, position.dy - 24));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.selectedIndex != selectedIndex;
  }
}

class _ChartPoint {
  final String label;
  final double value;

  _ChartPoint({required this.label, required this.value});
}

class _ChartPointBuilder {
  final String label;
  int count = 0;

  _ChartPointBuilder({required this.label});
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF7C7BFF)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SmallStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
