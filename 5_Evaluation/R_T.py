# -*- coding: utf-8 -*-
"""
Created on Fri Dec 29 15:33:46 2023

@author: Rasoul
"""

import cv2
import numpy as np
import cv2.aruco as aruco

# # Define the camera matrix D435i
# fx = 913.316  # Focal length in x-direction
# fy = 912.385  # Focal length in y-direction
# cx = 640.192       # Principal point x-coordinate
# cy = 356.755       # Principal point y-coordinate

# Define the camera matrix D415
fx = 910.718994140625  # Focal length in x-direction
fy = 908.876159667969  # Focal length in y-direction
cx = 634.168640136719       # Principal point x-coordinate
cy = 355.472259521484       # Principal point y-coordinate

camera_matrix = np.array([[fx, 0, cx],
                          [0, fy, cy],
                          [0, 0, 1]])

# Define the distortion coefficients
k1 = 0.0
k2 = 0.0
k3 = 0.0
p1 = 0.0
p2 = 0.0

distortion_coefficients = np.array([k1, k2, p1, p2, k3])

filename = 'color_frame_0.png'

image = cv2.imread(filename)
# Convert the image to grayscale if needed
gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# # Apply contrast enhancement using histogram equalization
# enhanced_image = cv2.equalizeHist(gray_image)

# Apply Gaussian blur to the image
blurred = cv2.GaussianBlur(gray_image, (0, 0), 3)

# Apply the unsharp mask to enhance details
image = cv2.addWeighted(gray_image, 1.5, blurred, -0.5, 0)

# # Display the image
# cv2.imshow("Image", gray_image)
# cv2.waitKey(0)


# # Display the sharpened image
# cv2.imshow("Sharpened Image", unsharp_image)
# cv2.waitKey(0)

# # Display the enhanced image
# cv2.imshow("Enhanced Image", enhanced_image)
# cv2.waitKey(0)
# cv2.destroyAllWindows()


aruco_dict = aruco.Dictionary_get(aruco.DICT_4X4_50)
board = aruco.CharucoBoard_create(5, 5, 0.04, 0.02, aruco_dict)

# gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
gray = image
corners, ids, _ = aruco.detectMarkers(gray, aruco_dict)

_, charuco_corners, charuco_ids = aruco.interpolateCornersCharuco(
    corners, ids, gray, board
)

_, rvec_ref, tvec_ref = aruco.estimatePoseCharucoBoard(
    charuco_corners, charuco_ids, board, camera_matrix, distortion_coefficients, None, None
)


R1, _ = cv2.Rodrigues(rvec_ref)

R_2_arr = np.array(R1)
num_rows = R_2_arr.shape[0]
R_2_arr_2d = R_2_arr.reshape(num_rows, -1)
np.savetxt('_R_abs.txt', R_2_arr_2d, delimiter=',', fmt='%.16f')


t_2_arr = np.array(tvec_ref)
num_rows = t_2_arr.shape[0]
t_2_arr_2d = t_2_arr.reshape(num_rows, -1)
np.savetxt('_t_abs.txt', t_2_arr_2d, delimiter=',', fmt='%.16f')
