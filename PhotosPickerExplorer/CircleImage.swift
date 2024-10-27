//
//  CircleImage.swift
//  PhotosPickerExplorer
//
//  Created by Kennedy Karimi on 26/10/2024.
//

import SwiftUI

struct CircleImage: View {
    var image_url: String
    var points: CGFloat
    
    var body: some View {
        Image(image_url)
            .resizable()
            .frame(width: points, height: points)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(Color.gray, lineWidth: 1) //won't be noticable with default image 'account_circle' since border already black but can be seen on any other image.
            }
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image_url: "account_circle", points: 90)
    }
}
