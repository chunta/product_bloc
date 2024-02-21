import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:math' as math show Random;

@immutable
abstract class ProductEvent extends Equatable {
  const ProductEvent();
}

class ProductInitEvent extends ProductEvent {
  @override
  List<Object> get props => [];
}

class Product {
  final String name;
  final int quatity;
  const Product({required this.name, required this.quatity});
}

@immutable
abstract class ProductState extends Equatable {}

class ProductInitState extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductLoadingState extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductLoadedState extends ProductState {
  ProductLoadedState(this.products);
  final List<Product> products;

  @override
  List<Object> get props => [products];
}

class ProductErrorState extends ProductState {
  ProductErrorState(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}

class Repository {
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 2));
    return const [
      Product(name: "1", quatity: 1),
      Product(name: "2", quatity: 2)
    ];
  }
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final Repository _repository = Repository();

  ProductBloc() : super(ProductInitState()) {
    on<ProductInitEvent>((event, emit) async {
      emit(ProductLoadingState());
      try {
        final products = await _repository.getProducts();
        emit(ProductLoadedState(products));
      } catch (e) {
        emit(ProductErrorState(e.toString()));
      }
    });
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Bloc Example',
      home: BlocProvider<ProductBloc>(
        create: (context) => ProductBloc(),
        child: Scaffold(
          appBar: AppBar(title: const Text('Bloc Example')),
          body: const MyAppTest()
        ),
      ),
    ),
  );
}

class MyAppTest extends StatelessWidget {
  const MyAppTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductInitState) {
          return TextButton(
            onPressed: () {
              BlocProvider.of<ProductBloc>(context).add(ProductInitEvent());
            },
            child: const Text("Get products"),
          );
        } else if (state is ProductLoadedState) {
          return Text("${state.products.length}");
        } else if (state is ProductLoadingState) {
          return const Text("Loading...");
        } else {
          return Text((state as ProductErrorState).error);
        }
      },
    );
  }
}

const names = [
  'Foo',
  'Bar',
  'Baz',
];

extension RandomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(math.Random().nextInt(length));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StreamController<String> stream;

  @override
  void initState() {
    super.initState();
    stream = StreamController<String>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("(60) build");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: StreamBuilder<String?>(
        stream: stream.stream,
        builder: (context, snapshot) {
          final button = TextButton(
            onPressed: () {
              stream.add(names.getRandomElement());
            },
            child: const Text('Pick a random name'),
          );
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return button;
            case ConnectionState.waiting:
              return button;
            case ConnectionState.active:
              return Column(
                children: [
                  Text(snapshot.data ?? ''),
                  button,
                ],
              );
            case ConnectionState.done:
              return const SizedBox();
          }
        },
      ),
    );
  }
}