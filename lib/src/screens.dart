// The app's screens: an overview, a task list and settings, in the project's look. Replace them with
// the screens drawn in Universal App Studio (design/pages/).
import 'package:material_ui/material_ui.dart';

import 'tasks.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state, required this.projectName});

  final AppState state;
  final String projectName;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _page = 0;

  static const _destinations = [
    (icon: Icons.home_outlined, selected: Icons.home, label: 'Overview'),
    (icon: Icons.check_box_outlined, selected: Icons.check_box, label: 'Tasks'),
    (
      icon: Icons.settings_outlined,
      selected: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 820;
    final colors = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final body = switch (_page) {
          0 => OverviewPage(
            state: widget.state,
            onAdd: () => setState(() => _page = 1),
          ),
          1 => TasksPage(state: widget.state),
          _ => SettingsPage(state: widget.state),
        };
        if (!wide) {
          return Scaffold(
            body: SafeArea(bottom: false, child: body),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _page,
              backgroundColor: colors.surface,
              indicatorColor: colors.primary.withValues(alpha: 0.14),
              onDestinationSelected: (i) => setState(() => _page = i),
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selected, color: colors.primary),
                    label: d.label,
                  ),
              ],
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _page,
                backgroundColor: colors.surface,
                extended: true,
                minExtendedWidth: 232,
                indicatorColor: colors.primary.withValues(alpha: 0.14),
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
                  child: Brand(name: widget.projectName),
                ),
                onDestinationSelected: (i) => setState(() => _page = i),
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selected, color: colors.primary),
                      label: Text(d.label),
                    ),
                ],
              ),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

class Brand extends StatelessWidget {
  const Brand({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            name.isEmpty ? '?' : name[0].toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// A scrolling page with a title, centred and width-limited on big screens.
class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.action,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: text.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.state, required this.onAdd});

  final AppState state;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hello = now.hour < 12
        ? 'Good morning'
        : (now.hour < 18 ? 'Good afternoon' : 'Good evening');
    final done = state.total - state.open;
    final share = state.total == 0 ? 0.0 : done / state.total;
    final next = state.filtered(Filter.open).take(4).toList();
    final theme = Theme.of(context);
    return PageFrame(
      title: state.name.isEmpty ? hello : '$hello, ${state.name}',
      subtitle: "Here's where things stand today.",
      children: [
        Row(
          children: [
            for (final (label, value) in [
              ('Open', state.open),
              ('Done today', state.doneToday(now)),
              ('All', state.total),
            ])
              Expanded(
                child: Card(
                  margin: EdgeInsets.only(
                    right: label == 'All' ? 0 : 8,
                    bottom: 16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$value',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        Panel(
          title: 'Up next',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (next.isEmpty)
                const EmptyState(
                  title: 'All done',
                  text: 'Nothing left to do. Enjoy it.',
                ),
              for (final t in next)
                TaskTile(task: t, onToggle: () => state.toggle(t.id)),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add a task'),
              ),
            ],
          ),
        ),
        Panel(
          title: 'Progress',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(share * 100).round()}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 8,
                  color: theme.colorScheme.secondary,
                  backgroundColor: theme.scaffoldBackgroundColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$done of ${state.total} tasks done.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.state});

  final AppState state;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _controller = TextEditingController();
  Filter _filter = Filter.all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    widget.state.add(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.state.filtered(_filter);
    return PageFrame(
      title: 'Tasks',
      subtitle: 'Add what needs doing and tick it off.',
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'What needs doing?',
                        labelText: 'New task',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => FilledButton(
                      onPressed: _controller.text.trim().isEmpty ? null : _add,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(64, 56),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<Filter>(
                  segments: const [
                    ButtonSegment(value: Filter.all, label: Text('All')),
                    ButtonSegment(value: Filter.open, label: Text('Open')),
                    ButtonSegment(value: Filter.done, label: Text('Done')),
                  ],
                  selected: {_filter},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _filter = s.first),
                ),
              ),
              const SizedBox(height: 12),
              if (shown.isEmpty)
                EmptyState(
                  title: _filter == Filter.done
                      ? 'Nothing done yet'
                      : 'No tasks here',
                  text: _filter == Filter.done
                      ? 'Ticked tasks show up here.'
                      : 'Add your first one above.',
                ),
              for (final t in shown)
                TaskTile(
                  task: t,
                  onToggle: () => widget.state.toggle(t.id),
                  onRemove: () => widget.state.remove(t.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.state});

  final AppState state;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final _name = TextEditingController(text: widget.state.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Settings',
      subtitle: 'Saved on this device as you type.',
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  hintText: 'Shown on the overview',
                ),
                autofillHints: const [AutofillHints.givenName],
                onChanged: (v) => widget.state.name = v,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: widget.state.reset,
                  child: const Text('Start again with the example tasks'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onRemove,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: CheckboxListTile(
          value: task.done,
          onChanged: (_) => onToggle(),
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            task.title,
            style: task.done
                ? TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  )
                : null,
          ),
          secondary: onRemove == null
              ? null
              : IconButton(
                  tooltip: 'Delete "${task.title}"',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
