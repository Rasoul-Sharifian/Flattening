# -*- coding: utf-8 -*-
"""
Created on Fri Jun 30 15:33:46 2023

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

filename = 'Color/color_frame_0.png'

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

ind = 0
for i in range(ind,ind + 255):
    print(i)
    filename = 'Color/color_frame_' + str(i) + '.png'
    
    image = cv2.imread(filename)
    
    aruco_dict = aruco.Dictionary_get(aruco.DICT_4X4_50)
    board = aruco.CharucoBoard_create(5, 5, 0.04, 0.02, aruco_dict)
    
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    # Apply Gaussian blur to the image
    blurred = cv2.GaussianBlur(gray, (0, 0), 3)

    # Apply the unsharp mask to enhance details
    gray = cv2.addWeighted(gray, 1.5, blurred, -0.5, 0)
    corners, ids, _ = aruco.detectMarkers(gray, aruco_dict)
    
    _, charuco_corners, charuco_ids = aruco.interpolateCornersCharuco(
        corners, ids, gray, board
    )
    
    _, rvec_new, tvec_new = aruco.estimatePoseCharucoBoard(
        charuco_corners, charuco_ids, board, camera_matrix, distortion_coefficients, None, None
    )

    # Outline all of the markers detected in our image
    QueryImg = aruco.drawDetectedMarkers(image, corners, borderColor=(0, 0, 255))

    # Only try to find CharucoBoard if we found markers
    if ids is not None and len(ids) > 10:

        # Get charuco corners and ids from detected aruco markers
        response, charuco_corners, charuco_ids = aruco.interpolateCornersCharuco(
                markerCorners=corners,
                markerIds=ids,
                image=gray,
                board=board)

        # Require more than 20 squares
        if response is not None and response > 10:
            # Estimate the posture of the charuco board, which is a construction of 3D space based on the 2D video 
            # pose, rvec, tvec = aruco.estimatePoseCharucoBoard(
            #         charuco_corners, 
            #         charuco_ids, 
            #         board, 
            #         camera_matrix, 
            #         distortion_coefficients, None, None)
            # if pose:
                # Draw the camera posture calculated from the gridboard
            QueryImg = aruco.drawAxis(image, camera_matrix, distortion_coefficients, rvec_new , tvec_new, 0.3)
        
    # Display our image
    cv2.imshow('QueryImage', QueryImg)
    cv2.imwrite('Color_with_axes/' + str(i) + '.png', QueryImg)
    cv2.waitKey(10)
    # Exit at the end of the video on the 'q' keypress
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break


    R1, _ = cv2.Rodrigues(rvec_ref)
    R2, _ = cv2.Rodrigues(rvec_new)
 
    transformation_matrix1 = np.hstack((R1, tvec_ref))
    transformation_matrix1 = np.vstack((transformation_matrix1, [0, 0, 0, 1]))
    
    transformation_matrix2 = np.hstack((R2, tvec_new))
    transformation_matrix2 = np.vstack((transformation_matrix2, [0, 0, 0, 1]))

    relative_transformation_matrix = np.dot(transformation_matrix2, np.linalg.inv(transformation_matrix1))
    
    relative_rotation_matrix = relative_transformation_matrix[:3, :3]
    relative_translation_vector = relative_transformation_matrix[:3, 3]
    
    relative_rotation_vector, _ = cv2.Rodrigues(relative_rotation_matrix)
    relative_roll, relative_pitch, relative_yaw = relative_rotation_vector
    
    relative_roll_normalized = np.unwrap([relative_roll])[0]
    relative_pitch_normalized = np.unwrap([relative_pitch])[0]
    relative_yaw_normalized = np.unwrap([relative_yaw])[0]
    
    relative_roll_deg = np.degrees(relative_roll_normalized)
    relative_pitch_deg = np.degrees(relative_pitch_normalized)
    relative_yaw_deg = np.degrees(relative_yaw_normalized)

    #print(relative_roll_deg)
    
    R_relative = np.matmul(R2, np.transpose(R1))
    # print("R_relative:")
    # print(R_relative)

    t_relative = tvec_new - np.matmul(R_relative, tvec_ref)
    # print("t_relative:")
    # print(t_relative)

    R_relative_arr = np.array(R_relative)
    num_rows = R_relative_arr.shape[0]
    R_relative_arr_2d = R_relative_arr.reshape(num_rows, -1)
    np.savetxt('r/' + str(i) + '_R_relative.txt', R_relative_arr_2d, delimiter=',', fmt='%.8f')

    t_relative_arr = np.array(t_relative)
    num_rows = t_relative_arr.shape[0]
    t_relative_arr_2d = t_relative_arr.reshape(num_rows, -1)
    np.savetxt('t/' + str(i) + '_t_relative.txt', t_relative_arr_2d, delimiter=',', fmt='%.8f')


    # R_2_arr = np.array(R2)
    # num_rows = R_2_arr.shape[0]
    # R_2_arr_2d = R_2_arr.reshape(num_rows, -1)
    # np.savetxt('/media/rasoul/830873c3-8201-4a0c-8abe-39d71bdf67d7/Flatenning/12_09_2023_4/1_Data Preparation/r_abs/'
    #            + str(i) + '_R_abs.txt', R_2_arr_2d, delimiter=',', fmt='%.16f')
    
    
    # t_2_arr = np.array(tvec_new)
    # num_rows = t_2_arr.shape[0]
    # t_2_arr_2d = t_2_arr.reshape(num_rows, -1)
    # np.savetxt('/media/rasoul/830873c3-8201-4a0c-8abe-39d71bdf67d7/Flatenning/12_09_2023_4/1_Data Preparation/t_abs/'
    #            + str(i) + '_t_abs.txt', t_2_arr_2d, delimiter=',', fmt='%.16f')
