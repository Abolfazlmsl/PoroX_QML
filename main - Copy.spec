# -*- mode: python ; coding: utf-8 -*-
import sys
sys.setrecursionlimit(5000)
block_cipher = None


a = Analysis(['Main.py'],
             pathex=['C:\\Users\\Abolfazl\\Desktop\\test_py\\test'],
             binaries=[],
             datas=[('C:\\Users\\Abolfazl\\Desktop\\test_py\\test\\main.qml', '.'),
			 ('C:\\Users\\Abolfazl\\Desktop\\test_py\\test\\Modules', 'Modules'),
			 ('C:\\Users\\Abolfazl\\Desktop\\test_py\\test\\Images', 'Images'),
			 ('C:\\Users\\Abolfazl\\Desktop\\test_py\\test\\Fonts', 'Fonts'),
			 ('C:\\Users\\Abolfazl\\AppData\\Roaming\\Python\\Python37\\site-packages\\PySide2\\plugins\\geometryloaders', 'geometryloaders'),
			 ('C:\\Users\\Abolfazl\\AppData\\Roaming\\Python\\Python37\\site-packages\\PySide2\\plugins\\renderers', 'renderers'),
			 ('C:\\Users\\Abolfazl\\AppData\\Roaming\\Python\\Python37\\site-packages\\array_split\\copyright.txt', 'array_split' ),
			 ('C:\\Users\\Abolfazl\\AppData\\Roaming\\Python\\Python37\\site-packages\\array_split\\license.txt', 'array_split' ),
			 ('C:\\Users\\Abolfazl\\AppData\\Roaming\\Python\\Python37\\site-packages\\array_split\\version.txt', 'array_split' )],
			  hiddenimports=['skimage.filters.thresholding', 'nrrd', 'cv2', 'origin', 'scipy.spatial.transform._rotation_groups',
			 'segmentation', 'BlatralFilter', 'mpslib', 'eas', 'sklearn', 'sklearn.neighbors._typedefs',
			 'sklearn.utils._cython_blas', 'sklearn.neighbors._quad_tree', 'sklearn.tree._criterion',
			 'sklearn.tree._utils', 'skimage.feature._orb_descriptor_positions', 'openpnm', 'porespy',
			 'sklearn.utils._weight_vector'],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='Main',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=True )
