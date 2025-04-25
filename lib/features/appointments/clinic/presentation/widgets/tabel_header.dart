
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';

class TableHeader extends StatelessWidget {
  const TableHeader({
    super.key,
    required this.tableHeaderName,
  });

  final String tableHeaderName;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var mainCubit = BlocProvider.of<MainCubit>(context);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              tableHeaderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: mainCubit.isDark ? Colors.black : Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}