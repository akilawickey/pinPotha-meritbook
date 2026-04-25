import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../models/post.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'add_post_screen.dart';
import 'post_details_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/mobile_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PostService _postService = PostService();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();
  
  List<Post> _posts = [];
  bool _loading = true;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _postsPerPage = 12;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPosts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null || authProvider.user!.email == null) return;

    setState(() {
      _loading = true;
    });

    try {
      // Ensure we have a fresh token with email claim
      await authProvider.user!.getIdToken(true);
      
      _postService.getAllPosts(authProvider.user!.email!).listen(
        (posts) {
          if (mounted) {
            setState(() {
              _posts = posts;
              _loading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _loading = false;
            });
            debugPrint('Error loading posts: $error');
            // Show error message to user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading posts: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        debugPrint('Error getting token: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onRefresh() async {
    _loadPosts();
    await Future.delayed(const Duration(milliseconds: 500));
    _refreshController.refreshCompleted();
  }

  List<Post> get _filteredPosts {
    if (_searchQuery.isEmpty) {
      return _posts;
    }
    final query = _searchQuery.toLowerCase();
    return _posts.where((post) {
      return post.note?.toLowerCase().contains(query) ?? false;
    }).toList();
  }

  List<Post> get _paginatedPosts {
    final start = (_currentPage - 1) * _postsPerPage;
    final end = start + _postsPerPage;
    return _filteredPosts.sublist(
      start,
      end > _filteredPosts.length ? _filteredPosts.length : end,
    );
  }

  int get _totalPages {
    return (_filteredPosts.length / _postsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('PinPotha'),
        elevation: 2,
      ),
      drawer: const MobileDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddPostScreen(),
                                ),
                              ).then((_) => _loadPosts());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Good Thought'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Inline Search Bar - Always visible
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search your good thoughts...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _currentPage = 1;
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _currentPage = 1;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Your Good Thoughts (${_filteredPosts.length})',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: _postsPerPage,
                                items: const [
                                  DropdownMenuItem(value: 6, child: Text('6')),
                                  DropdownMenuItem(value: 12, child: Text('12')),
                                  DropdownMenuItem(value: 24, child: Text('24')),
                                  DropdownMenuItem(value: 48, child: Text('48')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _currentPage = 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Show empty state or posts grid
                  _filteredPosts.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= _paginatedPosts.length) {
                                  return null;
                                }
                                final post = _paginatedPosts[index];
                                return _buildPostCard(post);
                              },
                              childCount: _paginatedPosts.length,
                            ),
                          ),
                        ),
                  if (_totalPages > 1 && _filteredPosts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildPagination(),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavigation(currentScreen: CurrentScreen.dashboard),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book_outlined,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No good thoughts yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start recording the good things you\'ve done!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPostScreen(),
                ),
              ).then((_) => _loadPosts());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Good Thought'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailsScreen(postId: post.postId),
            ),
          ).then((_) => _loadPosts());
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: post.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: post.photoUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.book,
                            size: 48,
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      app_date_utils.AppDateUtils.formatDate(post.timeStamp.date, format: 'dd MMM yyyy'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.note ?? 'No note',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          ...List.generate(
            _totalPages > 7 ? 7 : _totalPages,
            (index) {
              int page;
              if (_totalPages <= 7) {
                page = index + 1;
              } else if (_currentPage <= 3) {
                page = index < 5 ? index + 1 : _totalPages;
                if (index == 5) return const Text('...');
              } else if (_currentPage >= _totalPages - 2) {
                if (index == 0) return const Text('...');
                page = _totalPages - 5 + index;
              } else {
                if (index == 0) return const Text('...');
                if (index == 6) return const Text('...');
                page = _currentPage - 2 + index;
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _currentPage == page
                        ? Theme.of(context).primaryColor
                        : null,
                    foregroundColor: _currentPage == page
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                  child: Text('$page'),
                ),
              );
            },
          ),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

