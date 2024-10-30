//
//  CircleImage.swift
//  PhotosPickerExplorer
//
//  Created by Kennedy Karimi on 26/10/2024.
//

import SwiftUI

//Image possibilites: 1. Loading from Assets(String name) 2. Loading from a database url string(AsyncImage) 3. Selected from Gallery (Image)

struct CircleImage: View {
    var image_source: GlobalEnumerations.ImageSource
    var image_name: String
    var image_url: String
    var image: Image?
    var points: CGFloat
    
    var body: some View {
        if image_source == .name {
            Image(image_name) //Displaying an image from Assets using its String name.
                .foregroundStyle(Color.black)
                .font(Font.system(size: points, weight: .regular))
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(Color.gray, lineWidth: 1) //Won't be noticeable with default image 'account_circle' since border already black but can be seen on any other image.
                }
        } else if image_source == .url {
            //Aptly called Asynchronous Image. The AsyncImage will simply show a default gray placeholder if the URL string is invalid. And if the image can’t be loaded for some reason – if the user is offline, or if the image doesn’t exist – then the system will continue showing the same placeholder image. More: https://www.hackingwithswift.com/quick-start/swiftui/how-to-load-a-remote-image-from-a-url
            AsyncImage(url: URL(string: image_url)) { image in
                image.resizable() //Resulting image and the placeholder color are now resizable
            } placeholder: { //While url is loading, AsyncImage uses a red placeholder color over the frame.
                Color.red
            }
            .frame(width: points, height: points)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(Color.gray, lineWidth: 1) //Won't be noticeable with default image 'account_circle' since border already black but can be seen on any other image.
            }
        } else if image_source == .gallery {
            image? //Displaying an image that's been selected from gallery.
                .resizable()
                .frame(width: points, height: points)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(Color.gray, lineWidth: 1) //Won't be noticeable with default image 'account_circle' since border already black but can be seen on any other image.
                }
        }
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image_source: .name, image_name: "account_circle", image_url: "", image: nil, points: 100)
    }
}
