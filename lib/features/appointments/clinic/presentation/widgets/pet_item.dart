
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/core/thames/decorations.dart';
import 'package:squeak/core/thames/styles.dart';
import 'package:squeak/features/appointments/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:squeak/features/layout/controller/layout_cubit.dart';
import 'package:squeak/features/pets/models/pet_model.dart';

class Pet extends StatelessWidget {
  const Pet({
    super.key,
    required this.doctor,
    required this.cubit,
    required this.context,
  });

  final PetsData doctor;
  final ClinicCubit cubit;
  final dynamic context;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: double.infinity,
            decoration: Decorations.kDecorationBoxShadow(
              context: context,
              color: doctor.isSelected
                  ? MainCubit.get(context).isDark
                      ? Colors.grey[800]
                      : Colors.grey[300]
                  : MainCubit.get(context).isDark
                      ? Colors.black38
                      : Colors.white,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      doctor.imageName.isEmpty
                          ? AssetImageModel.defaultPetImage
                          : '$imageimageUrl${doctor.imageName}',
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    doctor.petName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (LayoutCubit.get(context).pets.length > 1)
          Shimmer.fromColors(
            baseColor: Colors.grey.shade400,
            highlightColor: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  widthFactor: .4,
                  child: Icon(
                    Icons.keyboard_arrow_right_outlined,
                  ),
                ),
                Align(
                  widthFactor: .4,
                  child: Icon(
                    Icons.keyboard_arrow_right_outlined,
                  ),
                ),
                Align(
                  widthFactor: .4,
                  child: Icon(
                    Icons.keyboard_arrow_right_outlined,
                  ),
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          )
      ],
    );
  }
}
