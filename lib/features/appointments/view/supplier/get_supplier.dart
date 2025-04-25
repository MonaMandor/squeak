import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:squeak/core/constant/global_function/global_function.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/core/thames/styles.dart';
import 'package:squeak/features/appointments/controller/clinic/appointment_cubit.dart';
import 'package:squeak/features/appointments/view/availability/availability_screen.dart';
import 'package:squeak/features/layout/controller/SearchCubit/search_cubit.dart';

import '../../../../core/constant/global_widget/toast.dart';
import '../../../../core/thames/decorations.dart';
import '../../../../generated/l10n.dart';
import '../../../layout/view/search/search_screen.dart';
import '../../../vetcare/view/pet_merge_screen.dart';
import '../../controller/clinic/appointment_state.dart';
import 'dart:io'; // Import for Platform and exit()
import 'package:flutter/services.dart'; // Import for SystemNavigator.pop()

class MySupplierScreen extends StatelessWidget {
  const MySupplierScreen({
    super.key,
    required this.petId,
    required this.isSpayed,
    required this.petNameFromAppoinmentIcon,
    required this.genderForPetFromAppoinmentScreen,
  });

  final String petId;
  final bool? isSpayed;
  final String? petNameFromAppoinmentIcon;
  final int? genderForPetFromAppoinmentScreen;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentCubit()..init(),
      child: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          var cubit = AppointmentCubit.get(context);
          return Scaffold(
              appBar: AppBar(
                title: Text(S.of(context).yourClinic),
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back), // Back button
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // Go back if possible
                    } else {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop(); // Close app on Android
                      } else if (Platform.isIOS) {
                        exit(0); // Close app on iOS
                      }
                    }
                  },
                ),
              ),
              body: cubit.suppliers == null || cubit.suppliers!.data.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: BlocProvider(
                        create: (context) => SearchCubit(),
                        child: BlocConsumer<SearchCubit, SearchState>(
                          listener: (context, state) {
                            if (state is FollowError) {
                              errorToast(
                                context,
                                state.error.errors.isNotEmpty
                                    ? state.error.errors.values.first.first
                                    : state.error.message,
                              );
                            }
                            if (state is FollowSuccess) {
                              if (state.isHavePet) {
                                navigateAndFinish(
                                  context,
                                  PetMergeScreen(
                                    Code: SearchCubit.get(context)
                                        .searchController
                                        .text,
                                    isNavigation: true,
                                  ),
                                );
                              } else {
                                cubit.init();
                              }
                            }
                          },
                          builder: (context, state) {
                            var cubit = SearchCubit.get(context);
                            return buildColumnSearchBody(
                              cubit,
                              state,
                              'https://lottie.host/2f7e7695-4b78-4226-bd69-20f23959b1e9/LTteLFlERO.json',
                              context,
                            );
                          },
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Search TextField
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: cubit.searchController,
                            onChanged: cubit.filterSuppliers,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: isArabic()
                                  ? 'ابحث بالاسم او الكود'
                                  : 'Search by name or code',
                              contentPadding: EdgeInsets.all(0),
                              filled: true,
                              counterStyle: FontStyleThame.textStyle(
                                context: context,
                                fontSize: 13,
                              ),
                              hintStyle: FontStyleThame.textStyle(
                                  context: context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontColor: MainCubit.get(context).isDark
                                      ? Colors.white54
                                      : Color.fromRGBO(0, 0, 0, .3)),
                              fillColor: MainCubit.get(context).isDark
                                  ? Colors.black26
                                  : Colors.grey.shade200,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        // ListView.builder for displaying filtered suppliers
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 80,
                                  decoration: Decorations.kDecorationBoxShadow(
                                    context: context,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      navigateToScreen(
                                        context,
                                        AvailabilityScreen(
                                          clinicInfo:
                                              cubit.filteredSuppliers[index],
                                          petId: petId,
                                          isSpayed: isSpayed,
                                          petNameFromAppoinmentIcon:
                                              petNameFromAppoinmentIcon,
                                          genderForPetFromAppoinmentScreen:
                                              genderForPetFromAppoinmentScreen,
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor:
                                                MainCubit.get(context).isDark
                                                    ? Colors.black38
                                                    : Colors.white,
                                            backgroundImage: NetworkImage(
                                              imageimageUrl +
                                                  cubit.filteredSuppliers[index]
                                                      .data.image,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                cubit.filteredSuppliers[index]
                                                    .data.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Icon(
                                                    IconlyBold.location,
                                                    color:
                                                        ColorTheme.secondColor,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        .5,
                                                    child: Text(
                                                      '${cubit.filteredSuppliers[index].data.address}, ${cubit.filteredSuppliers[index].data.city}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Icon(
                                            isArabic()
                                                ? Icons.keyboard_arrow_left
                                                : Icons.keyboard_arrow_right,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: cubit.filteredSuppliers.length,
                          ),
                        ),
                      ],
                    ));
        },
      ),
    );
  }
}
