import numpy

from scipy.interpolate import RegularGridInterpolator as rgi
from scipy import ndimage

from skimage.segmentation import watershed
from skimage.morphology import h_minima
from skimage.morphology import label

from sklearn.cluster import k_means


def readRawVolumeImage(filePath, sizeData):
    image = numpy.zeros((sizeData[0], sizeData[1], sizeData[2]), numpy.uint16, 'F')
    for k in range(sizeData[2]):
        stream = numpy.fromfile(filePath, numpy.uint16, sizeData[0] * sizeData[1], '', 2 * k * sizeData[0] * sizeData[1])
        image[:, :, k] = numpy.reshape(stream, sizeData[:2], 'F')
    return image


def innerRectangle2D(im_axialSLice):
    sizeIm = im_axialSLice.shape
    corners = numpy.zeros((2, 2), 'intp')
    found_upleft = False
    for d in range(sizeIm[0] + sizeIm[1] - 1):
        for i in range(d + 1):
            j = d - i
            if im_axialSLice[i, j] > 0:
                if found_upleft:
                    corners[0, 0] = max(corners[0, 0], i)
                    corners[0, 1] = max(corners[0, 1], j)
                else:
                    found_upleft = True
                    corners[0, 0] = i
                    corners[0, 1] = j
        if found_upleft:
            break

    found_lowright = False
    for d in range(2, sizeIm[0] + sizeIm[1] + 1):
        for i in range(1, d):
            j = d - i
            if im_axialSLice[-i, -j] > 0:
                if found_lowright:
                    corners[1, 0] = min(corners[1, 0], sizeIm[0] - i)
                    corners[1, 1] = min(corners[1, 1], sizeIm[1] - j)
                else:
                    found_lowright = True
                    corners[1, 0] = sizeIm[0] - i
                    corners[1, 1] = sizeIm[1] - j
        if found_lowright:
            break

    return corners


def thresholdvalue_otsu(data, nBin=256):
    hist = numpy.histogram(data, nBin)
    p = hist[0]/sum(hist[0])
    edges = hist[1]
    bin_m1 = numpy.array([numpy.mean(data[numpy.logical_and(edges[i] <= data, data < edges[i+1])])if i < nBin-1 else numpy.mean(data[numpy.logical_and(edges[i] <= data, data <= edges[i+1])]) for i in range(nBin)])
    bin_m1[p == 0] = 0
    w1 = numpy.cumsum(p)
    mu1 = numpy.cumsum(p*bin_m1)
    objective = (mu1[-1]*w1-mu1)**2/(w1*(1-w1))
    return edges[1+numpy.nanargmax(objective)]


def thresholdvalue_KI(data, nBin=256):
    hist = numpy.histogram(data, nBin)
    p = hist[0]/sum(hist[0])
    edges = hist[1]
    bin_m1 = numpy.zeros(nBin)
    bin_m2 = numpy.zeros(nBin)
    for i in range(nBin - 1):
        bin_data = data[numpy.logical_and(edges[i] <= data, data < edges[i + 1])].astype(float)
        bin_m1[i] = numpy.mean(bin_data)
        bin_m2[i] = numpy.mean(bin_data ** 2)
    bin_data = data[numpy.logical_and(edges[-2] <= data, data <= edges[-1])].astype(float)
    bin_m1[-1] = numpy.mean(bin_data)
    bin_m2[-1] = numpy.mean(bin_data ** 2)
    logInd = p == 0
    bin_m1[logInd] = 0
    bin_m2[logInd] = 0

    class1_m0 = numpy.cumsum(p)
    class1_m1 = numpy.cumsum(p * bin_m1) / class1_m0
    class1_m2 = numpy.cumsum(p * bin_m2) / class1_m0
    class1_var = class1_m2 - class1_m1 ** 2
    class1_m0 = numpy.insert(class1_m0, 0, 0)
    class1_var = numpy.insert(class1_var, 0, 0)

    class2_m0 = numpy.cumsum(numpy.flip(p))
    class2_m1 = numpy.cumsum(numpy.flip(p * bin_m1)) / class2_m0
    class2_m2 = numpy.cumsum(numpy.flip(p * bin_m2)) / class2_m0
    class2_var = class2_m2 - class2_m1 ** 2
    class2_m0 = numpy.append(numpy.flip(class2_m0), 0)
    class2_var = numpy.append(numpy.flip(class2_var), 0)

    objective = class1_m0 * numpy.log(class1_var) + class2_m0 * numpy.log(class2_var) - 2 * (class1_m0 * numpy.log(class1_m0) + class2_m0 * numpy.log(class2_m0))
    objective[numpy.logical_not(numpy.isfinite(objective))] = float('inf')
    return edges[numpy.nanargmin(objective)]


def binarize_globalThreshold(image, method, *args, **kwargs):
    if method == 'otsu':
        s = numpy.shape(image)
        if len(s)==2:
            thresh = thresholdvalue_otsu(image.flatten(), *args, **kwargs)
            binarized = image < thresh
        else:
            thresh = thresholdvalue_otsu(image[:,:,1].flatten(), *args, **kwargs)
            binarized = numpy.zeros((s[0],s[1]))
            for i in range(s[0]):
                for j in range(s[1]):
                    if image[i][j][1] > thresh:
                        binarized[i][j] = 1 
    elif method == 'KI':
        s = numpy.shape(image)
        if len(s)==2:
            thresh = thresholdvalue_KI(image.flatten(), *args, **kwargs)
            binarized = image < thresh
        else:
            thresh = thresholdvalue_KI(image[:,:,1].flatten(), *args, **kwargs)
            binarized = numpy.zeros((s[0],s[1]))
            for i in range(s[0]):
                for j in range(s[1]):
                    if image[i][j][1] > thresh:
                        binarized[i][j] = 1 
    
    binarized = numpy.array(binarized, dtype=bool)
    return thresh, binarized


def obtain_nWin(sizeInput, sizeWindow, stride, shape):
    sizeWindow = numpy.array(sizeWindow).astype('intp')
    stride = numpy.array(stride).astype('intp')
    if shape == 'valid':
        nStride = numpy.floor((sizeInput - sizeWindow) / stride).astype('intp')
    elif shape == 'same':
        nStride = numpy.ceil((sizeInput - 1) / stride).astype('intp')
    nWin = 1 + nStride
    return nWin


def obtain_margins(sizeInput, sizeWindow, stride,  shape):
    nWin = obtain_nWin(sizeInput, sizeWindow, stride,  shape)
    sizeRequired = sizeWindow + (nWin-1) * stride
    if shape == 'valid':
        margin_pre = numpy.floor(0.5 * (sizeInput - sizeRequired)).astype('intp')
        margin_post = numpy.ceil(0.5 * (sizeInput - sizeRequired)).astype('intp')
    elif shape == 'same':
        margin_pre = numpy.floor(0.5 * (sizeRequired - sizeInput)).astype('intp')
        margin_post = numpy.ceil(0.5 * (sizeRequired - sizeInput)).astype('intp')
    return margin_pre, margin_post, sizeRequired


def slidingOperation(image, operations, sizeWindow, stride, shape):
    sizeInput = numpy.array(image.shape)
    margin_pre, margin_post, sizeRequired = obtain_margins(sizeInput, sizeWindow, stride, shape)
    if shape == 'valid':
        imageRequired = image[margin_pre[0]:margin_pre[0] + sizeRequired[0], margin_pre[1]:margin_pre[1] + sizeRequired[1], margin_pre[2]:margin_pre[2] + sizeRequired[2]]
    elif shape == 'same':
        padWidth = [(margin_pre[elem], margin_post[elem]) for elem in range(len(sizeWindow))]
        imageRequired = numpy.pad(image, tuple(padWidth), 'edge')

    nWin = obtain_nWin(sizeInput, sizeWindow, stride, shape)
    I = [(i*stride[0], i*stride[0]+sizeWindow[0]) for i in range(nWin[0])]
    J = [(j*stride[1], j*stride[1]+sizeWindow[1]) for j in range(nWin[1])]
    K = [(k*stride[2], k*stride[2]+sizeWindow[2]) for k in range(nWin[2])]

    return numpy.array([[[[operation(imageRequired[i1:i2, j1:j2, k1:k2]) for operation in operations] for k1, k2 in K] for j1, j2 in J] for i1, i2 in I])


def obtain_interpolationCoord(sizeInput, sizeWindow, stride,  shape):
    margin_pre, margin_post, sizeRequired = obtain_margins(sizeInput, sizeWindow, stride, shape)
    coordRes = []
    coordOutput = []
    edgesInd = numpy.zeros([3, 2])
    for i in range(3):
        d = numpy.linspace(0, 1, num=2 * sizeRequired[i] + 1)
        coordRes.append(d[sizeWindow[i]:-sizeWindow[i]:2 * stride[i]])
        if shape == 'valid':
            coord = []
            firstEnter = True
            for j in range(1, 2 * sizeRequired[i], 2):
                if coordRes[i][0] <= d[j] <= coordRes[i][-1]:
                    coord.append(d[j])
                    edgesInd[i, 1] = j
                    if firstEnter:
                        firstEnter = False
                        edgesInd[i, 0] = j
            coordOutput.append(coord)
            edgesInd[i, :] = 0.5 * (edgesInd[i, :] - 1) + margin_pre[i]

        elif shape == 'same':
            coordOutput.append(d[1 + 2 * margin_pre[i]: -2 * margin_post[i] - 1: 2])
            edgesInd[i, 0] = 0
            edgesInd[i, 1] = sizeInput[i] - 1
    edgesInd = edgesInd.astype('intp')
    sizeOutput = [len(coordOutput[0]), len(coordOutput[1]), len(coordOutput[2])]
    return coordRes, coordOutput, sizeOutput, edgesInd


def binarize_Niblack(image, sizeWindow, stride, shape='valid'):
    param_lambda = 0
    sizeInput=numpy.array(image.shape)

    coordRes, coordOutput, sizeOutput, edgesInd = obtain_interpolationCoord(sizeInput, sizeWindow, stride,  shape)
    res = slidingOperation(image, [numpy.mean, numpy.std], sizeWindow, stride, shape)
    interpolator = rgi(tuple(coordRes), res[:, :, :, 0]+param_lambda*res[:, :, :, 1])

    binarized = numpy.zeros(sizeInput, bool)
    I = range(edgesInd[0, 0], edgesInd[0, 1] + 1)
    for i in range(sizeOutput[0]):
        binarized[I[i], edgesInd[1, 0]:edgesInd[1, 1]+1, edgesInd[2, 0]:edgesInd[2, 1]+1] = interpolator(tuple(numpy.meshgrid(coordOutput[0][i], coordOutput[1], coordOutput[2], indexing='ij', sparse=True))) <= image[I[i], edgesInd[1, 0]:edgesInd[1, 1]+1, edgesInd[2, 0]:edgesInd[2, 1]+1]
    return binarized, edgesInd


def binarize_Sauvola(image, sizeWindow, stride, shape='valid'):
    param_lambda = -0.4
    sizeInput=numpy.array(image.shape)

    coordRes, coordOutput, sizeOutput, edgesInd = obtain_interpolationCoord(sizeInput, sizeWindow, stride,  shape)
    res = slidingOperation(image, [numpy.mean, numpy.std], sizeWindow, stride, shape)
    interpolator = rgi(tuple(coordRes), res[:, :, :, 0]*(1 +param_lambda*(res[:, :, :, 1] / numpy.max(res[:, :, :, 1])-1)))

    binarized = numpy.zeros(sizeInput, bool)
    I = range(edgesInd[0, 0], edgesInd[0, 1] + 1)
    for i in range(sizeOutput[0]):
        binarized[I[i], edgesInd[1, 0]:edgesInd[1, 1]+1, edgesInd[2, 0]:edgesInd[2, 1]+1] = interpolator(tuple(numpy.meshgrid(coordOutput[0][i], coordOutput[1], coordOutput[2], indexing='ij', sparse=True))) <= image[I[i], edgesInd[1, 0]:edgesInd[1, 1]+1, edgesInd[2, 0]:edgesInd[2, 1]+1]
    return binarized, edgesInd


def label_watershed(image):
    thresh, binary = binarize_globalThreshold(image, 'otsu')
    gradMag = ndimage.gaussian_gradient_magnitude(image.astype(float), 1.5)
    # wb = numpy.sum(binary)/binary.size
    tol = numpy.sqrt(max(numpy.var(gradMag[binary]), numpy.var(gradMag[~binary])))
    markers = ndimage.label(h_minima(gradMag, tol))[0]

    labels = watershed(gradMag, markers=markers)

    (values, counts) = numpy.unique(labels[binary], return_counts=True)
    labelBG = values[numpy.argmax(counts)]
    binary = labels != labelBG
    labels[labels == 0] = labelBG
    labels[binary] = 0
    return thresh, binary, labels


def findLabels(image_binary):
    return label(image_binary, background=True)

def binarize_kmeans(image):
    labels = k_means(image.reshape((-1, 1)), 2)[1].reshape(image.shape)
    thresh, binary = binarize_globalThreshold(image, 'KI')
    (values, counts) = numpy.unique(labels[binary], return_counts=True)
    labelBG = values[numpy.argmax(counts)]
    return thresh, binary, labels == labelBG

