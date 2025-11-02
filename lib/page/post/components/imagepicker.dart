import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class ImagePickerScreen extends StatefulWidget {
  final List<File>? initialImages;
  final Function(List<File>)? onImagesSelected;
  final int maxImages;

  const ImagePickerScreen({
    super.key,
    this.initialImages,
    this.onImagesSelected,
    this.maxImages = 9,
  });

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen>
    with SingleTickerProviderStateMixin {
  List<File> _selectedImages = []; // 存储已选择的图片
  bool _isLoading = false;
  bool _showAlbumSelector = false;

  // 相册和资源管理
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;
  List<AssetEntity> _assets = [];
  int _currentPage = 0;
  final int _pageSize = 60; // 每次加载图片的数量
  bool _hasMoreToLoad = true;
  bool _isLoadingMore = false;

  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _albumAnimation;

  // 已选择的资源
  final List<AssetEntity> _selectedAssets = [];
  // 缩略图选项
  final ThumbnailOption _thumbOption = const ThumbnailOption(
    size: const ThumbnailSize.square(200),
    quality: 80,
  );

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _albumAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 如果有初始图片，则加载
    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      _selectedImages = List.from(widget.initialImages!);
    }

    // 页面加载后检查权限并加载相册
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndLoadAlbums();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 检查权限并加载相册
  Future<void> _checkPermissionsAndLoadAlbums() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (ps.isAuth) {
      // 权限已获取，加载相册
      _loadAlbums();
    } else if (ps.hasAccess) {
      // 有限访问权限
      _loadAlbums();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('您已授予有限的相册访问权限'),
            backgroundColor: Color(0xFF323232),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // 权限被拒绝
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  // 显示权限被拒绝的对话框
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF6201E7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '需要相册权限',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              '此功能需要访问您的相册。请在设置中打开相册权限。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  PhotoManager.openSetting();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6201E7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 0,
                ),
                child: const Text(
                  '打开设置',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // 加载相册列表
  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);

    try {
      // 使用photo_manager获取相册列表
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image, // 只获取图片
        onlyAll: false, // 获取所有相册，不只是"全部"相册
      );

      setState(() {
        _albums = albums;
        if (albums.isNotEmpty) {
          _currentAlbum = albums.first; // 默认选择第一个相册（通常是"全部"）
          _loadAssetsForCurrentAlbum();
        }
      });
    } catch (e) {
      debugPrint('加载相册失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载相册失败: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 加载当前选中相册的资源
  Future<void> _loadAssetsForCurrentAlbum() async {
    if (_currentAlbum == null) return;

    setState(() => _isLoading = true);

    try {
      // 获取相册中的资源（图片）
      final assets = await _currentAlbum!.getAssetListPaged(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        if (_currentPage == 0) {
          _assets = assets;
        } else {
          _assets.addAll(assets);
        }

        _hasMoreToLoad = assets.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('加载相册资源失败: $e');
      setState(() => _isLoading = false);
    }
  }

  // 加载更多资源
  Future<void> _loadMoreAssets() async {
    if (!_hasMoreToLoad || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      await _loadAssetsForCurrentAlbum();
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  // 切换相册选择器的显示状态
  void _toggleAlbumSelector() {
    setState(() {
      _showAlbumSelector = !_showAlbumSelector;
    });

    if (_showAlbumSelector) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  // 选择相册
  void _selectAlbum(AssetPathEntity album) {
    if (_currentAlbum?.id == album.id) {
      _toggleAlbumSelector();
      return;
    }

    setState(() {
      _currentAlbum = album;
      _currentPage = 0;
      _assets = [];
      _showAlbumSelector = false;
    });

    _animationController.reverse();
    _loadAssetsForCurrentAlbum();
  }

  // 选择或取消选择资源
  void _toggleAssetSelection(AssetEntity asset) async {
    // 检查是否已经选择了最大数量的图片
    if (!_selectedAssets.contains(asset) &&
        _selectedAssets.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('最多只能选择${widget.maxImages}张图片'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(8),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
      } else {
        _selectedAssets.add(asset);
      }
    });

    // 更新已选图片的File列表
    await _updateSelectedFiles();
  }

  // 更新已选图片的File列表
  Future<void> _updateSelectedFiles() async {
    List<File> files = [];

    for (final asset in _selectedAssets) {
      final file = await asset.file;
      if (file != null) {
        files.add(file);
      }
    }

    setState(() {
      _selectedImages = files;
    });

    // 通知父组件
    if (widget.onImagesSelected != null) {
      widget.onImagesSelected!(files);
    }
  }

  // 预览已选择的图片
  void _previewSelectedImages(int initialIndex) {
    if (_selectedAssets.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => _FullScreenImageViewer(
              assets: _selectedAssets,
              initialIndex: initialIndex,
              onDelete: (index) {
                setState(() {
                  _selectedAssets.removeAt(index);
                  _updateSelectedFiles();
                });
              },
            ),
      ),
    );
  }

  // 清空选择
  void _clearSelection() {
    setState(() {
      _selectedAssets.clear();
    });
    _updateSelectedFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: _toggleAlbumSelector,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _showAlbumSelector ? Colors.grey[100] : Colors.transparent,
              border: Border.all(
                color: _showAlbumSelector ? Colors.grey.shade300 : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentAlbum?.name ?? '相册',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _showAlbumSelector ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context, _selectedImages);
          },
        ),
        actions: [
          AnimatedOpacity(
            opacity: _selectedImages.isNotEmpty ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: TextButton(
              onPressed:
                  _selectedImages.isNotEmpty
                      ? () => Navigator.pop(context, _selectedImages)
                      : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    _selectedImages.isNotEmpty
                        ? const Color(0xFF6201E7)
                        : Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                '完成',
                style: TextStyle(
                  color:
                      _selectedImages.isNotEmpty
                          ? Colors.white
                          : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 已选图片计数器
              if (_selectedAssets.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6201E7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6201E7).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 预览按钮
                      InkWell(
                        onTap: () => _previewSelectedImages(0),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.remove_red_eye,
                                color: const Color(0xFF6201E7),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '预览',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 图片计数器
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6201E7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_selectedAssets.length}/${widget.maxImages}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 相册资源网格
              Expanded(
                child:
                    _isLoading && _assets.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFF6201E7),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '正在加载相册...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                        : _buildAssetsGrid(),
              ),

              // 底部操作栏
              if (_selectedAssets.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 预览按钮
                      _buildActionButton(
                        icon: Icons.remove_red_eye,
                        label: '预览',
                        onTap:
                            _selectedAssets.isNotEmpty
                                ? () => _previewSelectedImages(0)
                                : null,
                      ),

                      // 清空按钮
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: '清空',
                        onTap:
                            _selectedAssets.isNotEmpty ? _clearSelection : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // 相册选择器下拉菜单 - 使用动画
          AnimatedBuilder(
            animation: _albumAnimation,
            builder: (context, child) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                height:
                    _showAlbumSelector
                        ? MediaQuery.of(context).size.height *
                            0.5 *
                            _albumAnimation.value
                        : 0,
                child: ClipRRect(
                    child: BackdropFilter(
                      filter:
                          _showAlbumSelector
                              ? ImageFilter.blur(
                                sigmaX: 5 * _albumAnimation.value,
                                sigmaY: 5 * _albumAnimation.value,
                              )
                              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: _albums.length,
                          itemBuilder: (context, index) {
                            final album = _albums[index];
                            final isSelected = _currentAlbum?.id == album.id;
                            return InkWell(
                              onTap: () => _selectAlbum(album),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6201E7).withOpacity(0.1)
                                      : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: const Color(0xFF6201E7),
                                        size: 20,
                                      )
                                    else
                                      Icon(
                                        Icons.folder_outlined,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        album.name,
                                        style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFF6201E7)
                                              : Colors.black87,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    FutureBuilder<int>(
                                      future: album.assetCountAsync,
                                      builder: (context, snapshot) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF6201E7).withOpacity(0.2)
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            snapshot.data != null
                                                ? '${snapshot.data}'
                                                : '...',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFF6201E7)
                                                  : Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建资源网格
  Widget _buildAssetsGrid() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            _loadMoreAssets();
          }
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _assets.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _assets.length) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6201E7),
                ),
              ),
            );
          }
          return _buildAssetTile(_assets[index]);
        },
      ),
    );
  }

  // 构建单个资源瓦片
  Widget _buildAssetTile(AssetEntity asset) {
    final isSelected = _selectedAssets.contains(asset);
    final selectedIndex = _selectedAssets.indexOf(asset) + 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 资源缩略图
        GestureDetector(
          onTap: () => _toggleAssetSelection(asset),
          child: Hero(
            tag: 'asset_${asset.id}',
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(1)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AssetEntityImage(
                    asset,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(200),
                    thumbnailFormat: ThumbnailFormat.jpeg,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error, color: Colors.grey[600]),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6201E7),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  // 选中蒙层
                  if (isSelected)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF6201E7),
                          width: 3,
                        ),
                        color: const Color(0xFF6201E7).withOpacity(0.2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // 选择指示器
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _toggleAssetSelection(asset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected
                        ? const Color(0xFF6201E7)
                        : Colors.white.withOpacity(0.7),
                border: Border.all(
                  color:
                      isSelected ? Colors.white : Colors.grey.shade400,
                  width: 2,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: const Color(0xFF6201E7).withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                        ],
              ),
              child:
                  isSelected
                      ? Center(
                        child: Text(
                          '$selectedIndex',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                      : null,
            ),
          ),
        ),

        // 视频时长指示器（如果是视频）
        if (asset.type == AssetType.video)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam, color: Colors.white, size: 10),
                  const SizedBox(width: 2),
                  Text(
                    _formatDuration(asset.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color:
                onTap != null
                    ? Colors.grey[50]
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border:
                onTap != null
                    ? Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    )
                    : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: onTap != null ? const Color(0xFF6201E7) : Colors.grey,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: onTap != null ? Colors.black87 : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 格式化视频时长
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// 全屏图片查看器
class _FullScreenImageViewer extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;
  final Function(int)? onDelete;

  const _FullScreenImageViewer({
    required this.assets,
    required this.initialIndex,
    this.onDelete,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  // 控制淡入淡出的动画控制器
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // 初始化动画控制器
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // 控件默认可见
    _fadeController.value = 1.0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _fadeController.forward();
    } else {
      _fadeController.reverse();
    }
  }

  void _deleteCurrentImage() {
    if (widget.onDelete != null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: Colors.red[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '删除图片',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              content: const Text(
                '确定要删除这张图片吗？',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete!(_currentIndex);

                    if (widget.assets.length <= 1) {
                      Navigator.of(context).pop();
                      return;
                    }

                    if (_currentIndex >= widget.assets.length - 1) {
                      setState(() {
                        _currentIndex = widget.assets.length - 2;
                        _pageController.jumpToPage(_currentIndex);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text(
                    '删除',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar:
          _showControls
              ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AppBar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${widget.assets.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete, size: 20),
                          ),
                          onPressed: _deleteCurrentImage,
                          tooltip: '删除这张图片',
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // 背景
            Container(color: Colors.black),

            // 图片预览
            PageView.builder(
              controller: _pageController,
              itemCount: widget.assets.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final asset = widget.assets[index];
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Hero(
                      tag: 'asset_${asset.id}',
                      child: AssetEntityImage(
                        asset,
                        isOriginal: true,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF07C160),
                                  strokeWidth: 2,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '加载中...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '无法加载图片',
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            // 渐变覆盖层 - 顶部
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _showControls
              ? FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionIcon(
                          icon: Icons.share,
                          label: '分享',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('分享功能待实现'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF323232),
                              ),
                            );
                          },
                        ),
                        _buildActionIcon(
                          icon: Icons.edit,
                          label: '编辑',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('编辑功能待实现'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF323232),
                              ),
                            );
                          },
                        ),
                        _buildActionIcon(
                          icon: Icons.delete,
                          label: '删除',
                          onTap: _deleteCurrentImage,
                          highlight: true,
                        ),
                        _buildActionIcon(
                          icon: Icons.save_alt,
                          label: '保存',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('保存功能待实现'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF323232),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: highlight ? Colors.red.withOpacity(0.2) : Colors.black38,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      highlight ? Colors.red.withOpacity(0.5) : Colors.white24,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: highlight ? Colors.red : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: highlight ? Colors.red : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
