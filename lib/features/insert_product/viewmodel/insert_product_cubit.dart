import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/picked_image.dart';
import '../../../data/repositories/user_product_repository.dart';
import '../../../data/services/image_picker_service.dart';
import 'insert_product_state.dart';

class InsertProductCubit extends Cubit<InsertProductState> {
  InsertProductCubit({
    required this.repository,
    required this.imageService,
  }) : super(const InsertProductIdle());

  final UserProductRepository repository;
  final ImagePickerService imageService;

  PickedImage? pickedImage;

  Future<PickedImage?> pickImage(ImageSource source) async {
    final image = await imageService.pickImage(source);
    if (image != null) pickedImage = image;
    return image;
  }

  Future<void> submit({
    required String title,
    required String priceText,
    required String description,
    required String category,
    PickedImage? image,
  }) async {
    if (title.trim().isEmpty) {
      emit(const InsertProductFailure('Judul wajib diisi.'));
      return;
    }
    final price = double.tryParse(priceText.trim());
    if (price == null || price < 0) {
      emit(const InsertProductFailure('Harga tidak valid.'));
      return;
    }
    if (description.trim().isEmpty) {
      emit(const InsertProductFailure('Deskripsi wajib diisi.'));
      return;
    }
    if (category.trim().isEmpty) {
      emit(const InsertProductFailure('Pilih kategori.'));
      return;
    }
    final picked = image ?? pickedImage;
    if (picked == null) {
      emit(const InsertProductFailure('Pilih foto produk terlebih dahulu.'));
      return;
    }
    pickedImage = picked;

    emit(const InsertProductSubmitting());
    try {
      final imageUrl = await imageService.uploadImage(picked);

      final product = await repository.create(
        title: title.trim(),
        price: price,
        description: description.trim(),
        category: category.trim(),
        imageUrl: imageUrl,
      );

      emit(InsertProductSuccess(product));
    } on AppException catch (e) {
      emit(InsertProductFailure(e.message));
    } catch (e) {
      emit(InsertProductFailure(e.toString()));
    }
  }

  void reset() {
    pickedImage = null;
    emit(const InsertProductIdle());
  }
}
