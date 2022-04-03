# -*- mode: python ; coding: utf-8 -*-
import sys
sys.setrecursionlimit(5000)

block_cipher = None


a = Analysis(['PoroX.py'],
             pathex=['C:\\Users\\Abolfazl\\Desktop\\test_py\\test'],
             binaries=[],
             datas=[('C:\\Users\\Abolfazl\\Desktop\\Porox\\main.qml', '.'),
			 ('C:\\Users\\Abolfazl\\Desktop\\Porox\\Modules', 'Modules'),
			 ('C:\\Users\\Abolfazl\\Desktop\\Porox\\Images', 'Images'),
			 ('C:\\Users\\Abolfazl\\Desktop\\Porox\\Fonts', 'Fonts'),
			 ('C:\\Users\\Abolfazl\\Desktop\\Porox\\Functions', 'Functions'),
			 ('C:\\Users\\Abolfazl\\Desktop\\Porox\\REST', 'REST'),
			 ('F:\\Python3.7.1\\Lib\\site-packages\\PySide2\\plugins\\geometryloaders', 'geometryloaders'),
			 ('F:\\Python3.7.1\\Lib\\site-packages\\PySide2\\plugins\\renderers', 'renderers'),
			 ('F:\\Python3.7.1\\Lib\\site-packages\\array_split\\copyright.txt', 'array_split' ),
			 ('F:\\Python3.7.1\\Lib\\site-packages\\array_split\\license.txt', 'array_split' ),
			 ('F:\\Python3.7.1\\Lib\\site-packages\\array_split\\version.txt', 'array_split' )],
			  hiddenimports=['skimage.filters.thresholding', 'nrrd', 'cv2', 'origin', 'scipy.spatial.transform._rotation_groups',
			 'segmentation', 'BlatralFilter', 'mpslib', 'eas', 'sklearn', 'sklearn.neighbors._typedefs',
			 'sklearn.utils._cython_blas', 'sklearn.neighbors._quad_tree', 'sklearn.tree._criterion',
			 'sklearn.tree._utils', 'skimage.feature._orb_descriptor_positions', 'openpnm', 'porespy',
			 'sklearn.utils._weight_vector', 'sklearn.utils._typedefs', 'sklearn.neighbors._partition_nodes'],
             hookspath=[],
             hooksconfig={},
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
          name='PoroX',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=False,
          disable_windowed_traceback=False,
          target_arch=None,
          codesign_identity=None,
          entitlements_file=None , icon='C:\\Users\\Abolfazl\\Desktop\\test_py\\test\\PoroX-Icon.ico')
