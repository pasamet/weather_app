import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/geocoding_repository.dart';
import '../common/dimensions.dart';
import 'cubit.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Search'),
          ),
          body: Column(
            children: [
              _buildSearchField(state, context),
              Expanded(child: _buildResultsArea(state, context)),
            ],
          ),
        ),
      );

  Widget _buildSearchField(HomeState state, BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: TextField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'City Name',
            suffix: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : null,
          ),
          onChanged: (query) => context.read<HomeCubit>().onQueryChanged(query),
        ),
      );

  Widget _buildResultsArea(HomeState state, BuildContext context) =>
      switch (state) {
        EmptyState() => _buildEmpty(),
        LoadedState(:var items) when items.isEmpty => _buildNoResults(),
        LoadedState() => _buildList(state),
        ErrorState() => _buildError(state, context),
      };

  Widget _buildEmpty() =>
      const Center(child: Text('Enter a city name to search.'));

  Widget _buildList(LoadedState state) => ListView.builder(
        itemCount: state.items.length,
        itemBuilder: (context, index) =>
            _buildItem(state.items[index], context),
      );

  Widget _buildItem(NamedLocation item, BuildContext context) => ListTile(
        title: Text(item.name),
        onTap: () => context.read<HomeCubit>().onItemPressed(item),
      );

  Widget _buildError(ErrorState state, BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline),
          gap16,
          const Text('Search request failed.'),
          gap16,
          FilledButton(
            onPressed: state.isLoading
                ? null
                : () => context.read<HomeCubit>().onRetry(),
            child: const Text('Retry'),
          ),
        ],
      );

  Widget _buildNoResults() => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search),
          gap16,
          Text('No results found.'),
        ],
      );
}
