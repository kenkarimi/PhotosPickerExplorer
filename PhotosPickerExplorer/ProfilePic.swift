//
//  ProfilePic.swift
//  PhotosPickerExplorer
//
//  Created by Kennedy Karimi on 30/10/2024.
//

import SwiftUI

struct ProfilePic: View {
    var image_url: String
    var points: CGFloat
    
    var body: some View {
            //Aptly called Asynchronous Image. The AsyncImage will simply show a default gray placeholder if the URL string is invalid. And if the image can’t be loaded for some reason – if the user is offline, or if the image doesn’t exist – then the system will continue showing the same placeholder image. More: https://www.hackingwithswift.com/quick-start/swiftui/how-to-load-a-remote-image-from-a-url
            AsyncImage(url: URL(string: image_url)) { phase in
                if let image = phase.image { //If url loading was successful.
                    image
                        .resizable() //Resulting image and the placeholder color are now resizable
                        .frame(width: points, height: points)
                } else if phase.error != nil { //If url loadidng was unsuccessful.
                    Color.red
                } else { //While url is loading, AsyncImage uses a red placeholder color over the frame.
                    Image("account_circle") //Displaying an image from Assets using its String name.
                        .foregroundStyle(Color.black)
                        .font(Font.system(size: points, weight: .regular))
                }
            }
            .clipShape(Circle())
            .overlay {
                Circle().stroke(Color.gray, lineWidth: 1) //Won't be noticeable with default image 'account_circle' since border already black but can be seen on any other image.
            }
        
    }
}

struct ProfilePic_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePic(image_url: "", points: 100)
    }
}
