import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/cubit/profile_cubit.dart';
import '../../data/model/profile_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileInitial || state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProfileFailure) {
          return _ProfileMessage(
            icon: Icons.cloud_off_outlined,
            message: state.message,
            actionLabel: 'Try again',
            onAction: () =>
                context.read<ProfileCubit>().loadProfile(userId),
          );
        }
        if (state is ProfileLoaded) {
          return _ProfileDetails(
            profile: state.profile,
            onRefresh: () => context.read<ProfileCubit>().loadProfile(userId),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile, required this.onRefresh});

  final Profile profile;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = [
      profile.city,
      profile.state,
      profile.country,
    ].where((part) => part.isNotEmpty).join(', ');

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: profile.image.isEmpty
                        ? null
                        : NetworkImage(profile.image),
                    child: profile.image.isEmpty
                        ? Icon(
                            Icons.person_outline,
                            size: 44,
                            color: theme.colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.fullName.isEmpty ? 'Your profile' : profile.fullName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile.username.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '@${profile.username}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (profile.role.isNotEmpty || profile.company.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      [profile.role, profile.company]
                          .where((part) => part.isNotEmpty)
                          .join(' · '),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileSection(
            title: 'Contact information',
            children: [
              if (profile.email.isNotEmpty)
                _ProfileRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: profile.email,
                ),
              if (profile.phone.isNotEmpty)
                _ProfileRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: profile.phone,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileSection(
            title: 'Personal information',
            children: [
              if (profile.age > 0)
                _ProfileRow(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: '${profile.age}',
                ),
              if (profile.gender.isNotEmpty)
                _ProfileRow(
                  icon: Icons.person_outline,
                  label: 'Gender',
                  value: _capitalize(profile.gender),
                ),
            ],
          ),
          if (profile.address.isNotEmpty || location.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ProfileSection(
              title: 'Address',
              children: [
                if (profile.address.isNotEmpty)
                  _ProfileRow(
                    icon: Icons.location_on_outlined,
                    label: 'Street',
                    value: profile.address,
                  ),
                if (location.isNotEmpty)
                  _ProfileRow(
                    icon: Icons.map_outlined,
                    label: 'Location',
                    value: location,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
