import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanLineChart extends StatefulWidget {
  final List<String> statusList;
  const LaporanLineChart({super.key, required this.statusList});

  @override
  State<LaporanLineChart> createState() => _LaporanLineChartState();
}

class _LaporanLineChartState extends State<LaporanLineChart> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () {
                    setState(() {
                      selectedYear--;
                    });
                  },
                ),
                Text(
                  '$selectedYear',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    setState(() {
                      selectedYear++;
                    });
                  },
                ),
                const Spacer(),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        DateFormat('MMMM').format(DateTime(0, i + 1)),
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedMonth = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('laporan')
                      .where('status', whereIn: widget.statusList)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const SizedBox(
                    height: 180,
                    child: Center(child: Text('Tidak ada data untuk grafik')),
                  );
                }

                final thisMonthCounts = List<int>.filled(31, 0);
                final lastMonthCounts = List<int>.filled(31, 0);

                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final Timestamp? tgl = data['createdAt'];
                  if (tgl == null) continue;
                  final date = tgl.toDate();
                  if (date.year == selectedYear &&
                      date.month == selectedMonth) {
                    thisMonthCounts[date.day - 1]++;
                  } else if (date.year ==
                          (selectedYear - (selectedMonth == 1 ? 1 : 0)) &&
                      date.month ==
                          (selectedMonth == 1 ? 12 : selectedMonth - 1)) {
                    lastMonthCounts[date.day - 1]++;
                  }
                }

                final daysThisMonth = DateUtils.getDaysInMonth(
                  selectedYear,
                  selectedMonth,
                );
                final prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
                final prevYear =
                    selectedMonth == 1 ? selectedYear - 1 : selectedYear;
                final daysLastMonth = DateUtils.getDaysInMonth(
                  prevYear,
                  prevMonth,
                );

                // List data
                final List<FlSpot> thisMonthSpots = [
                  for (int i = 0; i < daysThisMonth; i++)
                    FlSpot(i + 1.0, thisMonthCounts[i].toDouble()),
                ];
                final List<FlSpot> lastMonthSpots = [
                  for (int i = 0; i < daysLastMonth; i++)
                    FlSpot(i + 1.0, lastMonthCounts[i].toDouble()),
                ];

                double maxY = [
                  ...thisMonthSpots.map((e) => e.y),
                  ...lastMonthSpots.map((e) => e.y),
                ].fold<double>(0, (prev, e) => e > prev ? e : prev);

                if (maxY < 5) {
                  maxY = maxY.ceilToDouble();
                } else {
                  maxY = ((maxY / 5).ceil() * 5).toDouble();
                }
                if (maxY == 0) maxY = 5;

                return SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Colors.white,
                      lineBarsData: [
                        LineChartBarData(
                          spots: thisMonthSpots,
                          isCurved: true,
                          barWidth: 3,
                          color: Colors.blue,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.08),
                          ),
                        ),
                        LineChartBarData(
                          spots: lastMonthSpots,
                          isCurved: true,
                          barWidth: 2,
                          color: Colors.amber.shade700,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                          dashArray: [7, 7],
                        ),
                      ],
                      minY: 0,
                      maxY: maxY + 2,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget:
                                (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval:
                                (daysThisMonth / 6)
                                    .ceilToDouble(), // maksimal 6 label
                            getTitlesWidget: (value, meta) {
                              if (value < 1 || value > daysThisMonth)
                                return const SizedBox();
                              // label tgl: 1, 7, 13, 19, 25, dst
                              if (daysThisMonth > 6 &&
                                  (value - 1) % ((daysThisMonth / 6).ceil()) !=
                                      0 &&
                                  value != daysThisMonth) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval:
                            1,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine:
                            (value) => FlLine(
                              color: Colors.grey.withOpacity(
                                0.3,
                              ),
                              strokeWidth: 1,
                            ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                );
              },
            ),
            // Legend
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 10, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Text('This Month', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  Icon(Icons.circle, size: 10, color: Colors.amber),
                  const SizedBox(width: 4),
                  const Text('Last Month', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
