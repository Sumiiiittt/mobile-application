
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../services/file_upload.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/global_ui_viewmodel.dart';
import '../../viewmodels/single_product_viewmodel.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SingleProductViewModel>(create: (_) => SingleProductViewModel(), child: EditProductBody());
  }
}

class EditProductBody extends StatefulWidget {
  const EditProductBody({Key? key}) : super(key: key);

  @override
  State<EditProductBody> createState() => _EditProductBodyState();
}

class _EditProductBodyState extends State<EditProductBody> {
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _productPriceController = TextEditingController();
  TextEditingController _productDescriptionController = TextEditingController();
  String productCategory = "";

  late GlobalUIViewModel _ui;
  late AuthViewModel _authViewModel;
  late CategoryViewModel _categoryViewModel;
  late SingleProductViewModel _singleProductViewModel;
  String? productId;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ui = Provider.of<GlobalUIViewModel>(context, listen: false);
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _categoryViewModel = Provider.of<CategoryViewModel>(context, listen: false);
      _singleProductViewModel = Provider.of<SingleProductViewModel>(context, listen: false);
      final args = ModalRoute.of(context)!.settings.arguments.toString();
      setState(() {
        productId = args;
      });
      print(args);
      getData(args);
    });
    super.initState();
  }

  void editProduct() async {
    _ui.loadState(true);
    try{
      final ProductModel data= ProductModel(
        imagePath: imagePath,
        imageUrl: imageUrl,
        categoryId: selectedCategory,
        productDescription: _productDescriptionController.text,
        productName: _productNameController.text,
        productPrice: num.parse(_productPriceController.text.toString()),
        userId: _authViewModel.loggedInUser!.userId,
      );
      await _authViewModel.editMyProduct(data, productId!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Success")));
      Navigator.of(context).pop();
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error")));
    }
    _ui.loadState(false);
  }

  getData(String args) async {
    _ui.loadState(true);
    try {
      await _categoryViewModel.getCategories();

      await _singleProductViewModel.getProducts(args);
      ProductModel? product = _singleProductViewModel.product;

      if (product != null) {
        _productNameController.text = product.productName ?? "";
        _productPriceController.text = product.productPrice==null ? "" : product.productPrice.toString();
        _productDescriptionController.text = product.productDescription ?? "";
        setState(() {
          selectedCategory = product.categoryId;
          imageUrl = product.imageUrl;
          imagePath = product.imagePath;
        });
      }
    } catch (e) {
      print(e);
    }
    _ui.loadState(false);
  }

  String? selectedCategory;

  // image uploader
  String? imageUrl;
  String? imagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    var selected = await _picker.pickImage(source: source, imageQuality: 100);
    if (selected != null) {
      setState(() {
        imageUrl = null;
        imagePath = null;
      });

      _ui.loadState(true);
      try {
        ImagePath? image = await FileUpload().uploadImage(selectedPath: selected.path);
        if (image != null) {
          setState(() {
            imageUrl = image.imageUrl;
            imagePath = image.imagePath;
          });
        }
      } catch (e) {
        print(e);
      }

      _ui.loadState(false);
    }
  }

  void deleteImage() async {
    _ui.loadState(true);
    try {
      await FileUpload().deleteImage(deletePath: imagePath.toString()).then((value) {
        setState(() {
          imagePath = null;
          imageUrl = null;
        });
      });
    } catch (e) {}

    _ui.loadState(false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SingleProductViewModel>(
      builder: (context, singleProductVM, child) {
        if(_singleProductViewModel.product== null)
          return Text("Error");
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black54,
            title: Text("Edit a product"),
          ),
          body: Consumer<CategoryViewModel>(builder: (context, categoryVM, child) {
            return SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _productNameController,
                        // validator: ValidateProduct.username,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          border: InputBorder.none,
                          label: Text("Product Name"),
                          hintText: 'Enter product name',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _productPriceController,
                        // validator: ValidateProduct.username,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          border: InputBorder.none,
                          label: Text("Product Price"),
                          hintText: 'Enter product price',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _productDescriptionController,
                        // validator: ValidateProduct.username,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          border: InputBorder.none,
                          label: Text("Product Description"),
                          hintText: 'Enter product description',
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Category",
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      DropdownButtonFormField(
                        borderRadius: BorderRadius.circular(10),
                        isExpanded: true,
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                        ),
                        icon: const Icon(Icons.arrow_drop_down_outlined),
                        items: categoryVM.categories.map((pt) {
                          return DropdownMenuItem(
                            value: pt.id.toString(),
                            child: Text(
                              pt.categoryName.toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          setState(() {
                            selectedCategory = newVal.toString();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Add Image"),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton(
                                onPressed: () {
                                  _pickImage(ImageSource.camera);
                                },
                                icon: Icon(Icons.camera)),
                            SizedBox(
                              width: 5,
                            ),
                            IconButton(
                                onPressed: () {
                                  _pickImage(ImageSource.gallery);
                                },
                                icon: Icon(Icons.photo))
                          ],
                        ),
                      ),
                      imageUrl != null
                          ? Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Image.network(
                                  imageUrl!,
                                  height: 50,
                                  width: 50,
                                ),
                                Text(imagePath.toString()),
                                IconButton(
                                    onPressed: () {
                                      deleteImage();
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.blue))),
                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 10)),
                            ),
                            onPressed: () {
                              editProduct();
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(fontSize: 20),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.orange))),
                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 10)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Back",
                              style: TextStyle(fontSize: 20),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }
    );
  }
}
