import pyrealsense2 as rs
import numpy as np
import cv2
import open3d as o3d

# Create a pipeline object
pipeline = rs.pipeline()

# Create a configuration object
config = rs.config()

# Tell the configuration to use a recorded .bag file
path ='20230703_154101.bag'

config.enable_device_from_file(path)

# Start the pipeline
pipeline.start(config)

# Get the intrinsic parameters of the color stream
profile = pipeline.get_active_profile()
depth_stream = profile.get_stream(rs.stream.depth)
color_stream = profile.get_stream(rs.stream.color)
color_intrinsics = color_stream.as_video_stream_profile().get_intrinsics()

# By default, the device plays back frames in real-time (similar to the live camera), 
# so if you don't process them fast enough, some will be dropped.
# You can disable this behavior to get all of the frames one-by-one

playback =profile.get_device().as_playback() # get playback device
playback.set_real_time(False) # disable real-time playback

# Create an align object
align = rs.align(rs.stream.color)

# Loop over each frame in the .bag file
frame_index = 0


while True:
    # Get a frame from the pipeline
    frames = pipeline.wait_for_frames()
    
    # Align the depth and color frames
    aligned_frames = align.process(frames)
    
    # Get the depth and color frames
    depth_frame = aligned_frames.get_depth_frame()
    color_frame = aligned_frames.get_color_frame()
    
    # Convert the color frame to a numpy array
    color_image = np.asanyarray(color_frame.get_data())
    color_image = cv2.cvtColor(color_image, cv2.COLOR_BGR2RGB)

    # Convert the depth frame to a numpy array
    depth_image = np.asanyarray(depth_frame.get_data())
    
    # Save the color image as a .png file
    cv2.imwrite("Color/color_frame_{}.png".format(frame_index), color_image)
    
    # Save the depth image as a .png file
    cv2.imwrite("Depth/depth_frame_{}.png".format(frame_index), depth_image)
    
    # Create a list to store the point cloud
    point_cloud = []
    colors = []
    # Loop over each pixel in the color image
    # for y in range(80 , color_image.shape[0] - 40):
    #     for x in range(600 , color_image.shape[1] - 130):
        
        
    # Create a black image with the specified dimensions
    image = np.zeros((color_image.shape[1], color_image.shape[0], 3), dtype=np.uint8)

    for y in range(color_image.shape[0]):
        for x in range(color_image.shape[1]):
            if (x == 0 & y == 0) :
                k = 12
            # Get the depth value at the corresponding pixel
            depth = depth_frame.get_distance(x, y)
           # print (depth)
            # Skip invalid depth values
            if np.isnan(depth) or depth <= 0:
                point = [0,0,0] 
                # Add the point to the point cloud
                point_cloud.append(point)
                

                    
                # Get the color of the corresponding pixel
                color = color_image[y, x]
                
                # Add the color to the colors list
                colors.append(color)
                continue
                
            # Map the color pixel to a 3D point in the point cloud
            point = rs.rs2_deproject_pixel_to_point(color_intrinsics, [x, y], depth)      

            # Add the point to the point cloud
            point_cloud.append(point)
            
            # Get the color of the corresponding pixel
            color = color_image[y, x]
            
            # Add the color to the colors list
            colors.append(color)
            
            ## project from point cloud to color image
            # corresponding_pixel = rs.rs2_project_point_to_pixel(color_intrinsics,point)
            # arr=np.array(corresponding_pixel)
            # arr1 = np.round(arr)
            # image[int(arr1[0]), int(arr1[1])] = color
            
   ## Display the resulting image (projected)
   #  cv2.imshow('image', image)
   #  cv2.waitKey(0)
   #  cv2.destroyAllWindows()         
    
    
    # Convert the point cloud and colors to numpy arrays
    point_cloud = np.array(point_cloud)
    colors = np.array(colors)
    
    # Create an Open3D point cloud object
    pcd = o3d.geometry.PointCloud()
    
    # Set the points property of the point cloud object
    pcd.points = o3d.utility.Vector3dVector(point_cloud)
    
    # Convert the colors from BGR to RGB
    colors = colors[:, ::-1]
    
    # Normalize the colors
    colors = colors / 255.0
    
    # Set the colors property of the point cloud object
    pcd.colors = o3d.utility.Vector3dVector(colors)
    
    # Save the point cloud as a .ply file
    o3d.io.write_point_cloud("PtCloud/frame_{}.ply".format(frame_index), pcd, write_ascii=True)
    
    # Increment the frame index
    frame_index += 1
    print(frame_index)
    
    # Check if the pipeline is still streaming
    if not pipeline.poll_for_frames():
        break

# Stop the pipeline
pipeline.stop()
