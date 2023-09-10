import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  
  CustomSearchDelegate(this.selectedFilter);
  String selectedFilter = ''; // Store the selected filter

  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for the search bar (e.g., clear query and filter)
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
      IconButton(
        onPressed: () {
          // Show a dialog or bottom sheet to allow users to select a filter
          _showFilterDialog(context);
        },
        icon: Icon(Icons.filter_list),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the search bar (e.g., back button)
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Build the search results based on the query and selected filter
    // Use the query and filter to filter and display results
    return Center(
      child: Text('Search results for: $query, Filter: $selectedFilter'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions while typing in the search bar
    // Use the query to suggest relevant terms or options
    final List<String> suggestions = [
      'Filter 1',
      'Filter 2',
      'Filter 3',
      // Add your filter options here
    ];

    final filteredSuggestions = suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = filteredSuggestions[index];
        return ListTile(
          title: Text(suggestion),
          onTap: () {
            // Perform filtering or other actions based on the selected filter
            // For example, update the selected filter and close the search bar
            selectedFilter = suggestion;
            close(context, suggestion);
          },
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select a Filter'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Add your filter options here as checkboxes or radio buttons
              ListTile(
                title: Text('Filter 1'),
                leading: Radio(
                  value: 'Filter 1',
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    // Update the selected filter (no need for setState)
                    selectedFilter = value.toString();
                  },
                ),
              ),
              ListTile(
                title: Text('Filter 2'),
                leading: Radio(
                  value: 'Filter 2',
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    // Update the selected filter (no need for setState)
                    selectedFilter = value.toString();
                  },
                ),
              ),
              // Add more filter options as needed
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Apply the selected filter and update the search results
              showResults(context);
              Navigator.of(context).pop();
            },
            child: Text('Apply Filter'),
          ),
        ],
      );
    },
  );
}

}