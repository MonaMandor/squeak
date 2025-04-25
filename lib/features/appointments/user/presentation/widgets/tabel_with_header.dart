
import 'package:flutter/material.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';

class TabelWithHeader extends StatelessWidget {
  const TabelWithHeader({
    super.key,
    required this.data,
    required this.width,
    required this.context,
  });

  final List<List<String>> data;
  final double width;
  final dynamic context;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: MainCubit.get(context).isDark ? Colors.black : Colors.grey,
        width: .5,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: {
        0: FlexColumnWidth(width),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: MainCubit.get(context).isDark
                ? ThemeData.dark().scaffoldBackgroundColor
                : Color(0xFFF7F7F7),
          ),
          children: data.first.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                cell,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
        ...data.skip(1).map((row) {
          return TableRow(
            children: row.map((cell) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(cell),
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }
}
