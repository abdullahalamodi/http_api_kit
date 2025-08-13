import 'package:flutter/material.dart';
import 'package:http_api_kit/async_widgets_kit/async_widgets_kit.dart';

class AsyncItemWidgetExample extends StatefulWidget {
  const AsyncItemWidgetExample({super.key});

  @override
  State<AsyncItemWidgetExample> createState() => _AsyncItemWidgetExampleState();
}

class _AsyncItemWidgetExampleState extends State<AsyncItemWidgetExample> {
  ItemStateModel<String> _stateModel = _loading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AsyncItemWidget(
          asyncData: _stateModel,
          dataBuilder: (data) {
            return Text(data);
          },
          onRetry: () {
            _fitechData();
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _stateModel = _data();
                setState(() {});
              },
              child: const Text('data'),
            ),
            ElevatedButton(
              onPressed: () {
                _stateModel = _loading();
                setState(() {});
              },
              child: const Text('loading'),
            ),
            ElevatedButton(
              onPressed: () {
                _stateModel = _error();
                setState(() {});
              },
              child: const Text('error'),
            ),
          ],
        )
      ],
    );
  }

  void _fitechData() async {
    _stateModel = _loading();
    setState(() {});
    await Future.delayed(const Duration(seconds: 2));
    _stateModel = _data();
    setState(() {});
  }
}

ItemStateModel<String> _data() {
  return ItemStateModel(
    loading: false,
    error: null,
    dataModel: 'dummy data',
  );
}

ItemStateModel<String> _loading() {
  return ItemStateModel(
    loading: true,
    error: null,
    dataModel: 'dummy data',
  );
}

ItemStateModel<String> _error() {
  return ItemStateModel(
    loading: false,
    error: 'Some error excure',
    dataModel: 'dummy data',
  );
}
