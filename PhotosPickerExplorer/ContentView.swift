//
//  ContentView.swift
//  PhotosPickerExplorer
//
//  Created by Kennedy Karimi on 25/10/2024.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    
    @State private var selectedVideo: PhotosPickerItem?
    @State private var selectedImageWithLabel: PhotosPickerItem?
    @State private var selectedImageWithTitle: PhotosPickerItem?
    @State private var selectedImage: PhotosPickerItem?
    @State private var stringImage: String?
    @State private var imageItem: Image?
    @State private var selectedImage2: PhotosPickerItem?
    @State private var stringImage2: String?
    @State private var imageItem2: Image?
    @State private var selectedImage3: PhotosPickerItem?
    @State private var stringImage3: String?
    @State private var imageItem3: Image?
    
    @State private var imageCreatedFromUIImage: Image?
    @State private var imageCreatedFromBase64String: Image?
    @State private var base64StringCreatedFromUIImage: String = ""
    @State private var image_source: GlobalEnumerations.ImageSource = .name
    @State private var image_url: String = "https://img.freepik.com/premium-psd/man-holding-up-phone-that-says-thumbs-up_382352-27775.jpg?w=996" //Alt image link: https://hws.dev/paul3.jpg
    
    var body: some View {
        VStack(alignment: .center) {
            /**
             * If you want more control over the data that is selected, adjust the matching parameter based on what you’re looking for. Use matching: .screenshots if you only want screenshots.
             * Use matching: .any(of: [.panoramas, .screenshots]) if you want either of those types.
             * Use matching: .not(.videos) if you want any media that isn’t a video.
             * Use matching: .any(of: [.images, .not(.screenshots)])) if you want all kinds of images except screenshots.
             * More on this: https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-select-pictures-using-photospicker
             */
            PhotosPicker(selection: $selectedVideo, matching: .videos, label: {
                Text("Select a video")
            }) //Has no title
            .padding(0)
            
            PhotosPicker(selection: $selectedImageWithLabel, matching: .images, label: {
                Image(systemName: "photo.on.rectangle")
                    .foregroundColor(Color.blue)
                    .imageScale(Image.Scale.large)
            }) //Has no title.
            .padding(0)
            
            PhotosPicker("Image goes here", selection: $selectedImageWithTitle, matching: .screenshots) //Has a no label
                .padding(0)
            
            //Image is a view from SwiftUI whereas UIImage is a view from UIKit, which can be converted to an object of type Data by using .jpegData() or .pngData(). The data object can then be converted to a Base64 string using .base64EncodedString(). Full UIImage example: https://www.hackingwithswift.com/forums/swiftui/encode-image-uiimage-to-base64/10103
            VStack {
                HStack {
                    imageCreatedFromUIImage? //Creating a SwiftUI Image from UIKit's UIImage. Doesn't show until onAppear runs the rest of the code.
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding(.top, 0)
                    imageCreatedFromBase64String? //Creating a SwiftUI Image from a base64 String.
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding(.top, 0)
                }
                Text("Base64 String from UIImage above:\n \(base64StringCreatedFromUIImage)") //Creating a base64 String from a UIKit UIImage.
                    .frame(height: 100) //String is too long.
                    .truncationMode(.tail)
            }
            .onAppear {
                let uiImage: UIImage = UIImage(imageLiteralResourceName: "account_circle")
                //UIImage -> Image
                imageCreatedFromUIImage = Image(uiImage: uiImage) //Creates a SwiftUI image from a UIKit image instance.
                
                //UIImage -> Data -> String(Base 64)
                let data: Data? = uiImage.jpegData(compressionQuality: 90) //No compression if pngData() is used.
                guard let data = data else { return }
                base64StringCreatedFromUIImage = data.base64EncodedString()
                
                //String(Base 64) -> Data -> UIImage -> Image
                let data2: Data? = Data(base64Encoded: base64StringCreatedFromUIImage, options: .ignoreUnknownCharacters)
                guard let data2 = data2 else { return }
                let uiImage2: UIImage? = UIImage(data: data2)
                guard let uiImage2 = uiImage2 else { return }
                imageCreatedFromBase64String = Image(uiImage: uiImage2) //As you can see, some quality is lost.
                
                //NB: A compression quality value of 20 in SwiftUI's UIImage.jpegData(compressionQuality: 0.2) and Android's Bitmap.compress(Bitmap.CompressFormat.JPEG, 20, baos) produce a similar level of compression.
                //The range for SwiftUI's 'compressionQuality' parameter is 0.0(max compression) to 1.0(min compression). A higher value means less compression, better image quality, larger file size.
                //The range for Android's 'quality' parameter is 0(amx compression) to 100(min compression). A higher value means less compression, better image quality, larger file size.
            }
            
            //EXAMPLE ONE: loadTransferable's type is Image.self so loaded is of type Image. As such, we use the ImageRenderer, which takes in a SwiftUI View(Image is a View) to convert the SwiftUI Image to a UIKit UIImage. The UIImage can then be converted into an object of type Data & then into a Base64 String from the compressed Data like we did with UIKits UIImage in the example above. More: https://developer.apple.com/documentation/swiftui/imagerenderer
            PhotosPicker(selection: $selectedImage, matching: .images, label: {
                if imageItem == nil { //Show either the default image or the image url if there's no selected image.
                    CircleImage(
                        image_source: .name,
                        image_name: "account_circle",
                        image_url: image_url,
                        image: nil,
                        points: 100
                    )
                } else if imageItem != nil { //Image has been selected from gallery.
                    CircleImage(
                        image_source: .gallery,
                        image_name: "",
                        image_url: "",
                        image: imageItem,
                        points: 100
                    )
                }
            })
            .onChange(of: selectedImage) { oldValue, newValue in //selectedImage is optional.
                Task { //Task is necessary because we can't pass function of type '(PhotosPickerItem?, PhotosPickerItem?) async -> Void' to parameter expecting synchronous function type.
                    if let loaded: Image = try? await newValue?.loadTransferable(type: Image.self) { //.loadTransferable(type: Image.self) asynchronously load an image from PhotosPickerItem and convert it into an Image type.
                        //imageItem = loaded //Or imageItem = Image(uiImage: uiImage) below.
                        let renderer: ImageRenderer = ImageRenderer(content: loaded)
                        guard let uiImage: UIImage = renderer.uiImage else { return }
                        imageItem = Image(uiImage: uiImage)
                        guard let data: Data = uiImage.jpegData(compressionQuality: 20) else { return } //'loaded' is now compressed as jpeg data. pngData() also works but doesn't compress.
                        stringImage = data.base64EncodedString() //Get the base 64 string of the compressed 'loaded'.
                    } else {
                        print("Image selection failed...")
                    }
                }
            }
            if let stringImage: String = stringImage {
                Text("Base64 String:\n \(stringImage)") //Creating a base64 String from a UIKit UIImage.
                    .frame(height: 100) //String is too long.
                    .truncationMode(.tail)
            } else {
                Text("Base64 String:")
            }
            
            //EXAMPLE TWO: loadTransferable's type is Data.self so loaded is of type Data. Instead of using the ImageRenderer like we did above to convert the SwiftUI Image to a UIKit UIImage, this method is simpler because we convert the Data itself to a UIImage. The UIImage can then be converted into an object of type Data that is even more compressed & then into a Base64 String from the compressed Data. More: https://www.reddit.com/r/swift/comments/1e2jm36/how_do_i_convert_a_swiftui_image_to_data/?rdt=43761
            PhotosPicker(selection: $selectedImage2, matching: .images, label: {
                if imageItem2 == nil { //Show either the default image or the image url if there's no selected image.
                    CircleImage(
                        image_source: .name,
                        image_name: "account_circle",
                        image_url: image_url,
                        image: nil,
                        points: 100
                    )
                } else if imageItem2 != nil { //Image has been selected from gallery.
                    CircleImage(
                        image_source: .gallery,
                        image_name: "",
                        image_url: "",
                        image: imageItem2,
                        points: 100
                    )
                }
            })
            .onChange(of: selectedImage2) { oldValue, newValue in //If selectedImage3 has changed, then it's no longer empty so just force unwrap.
                Task { //Task is necessary because we can't pass function of type '(PhotosPickerItem?, PhotosPickerItem?) async -> Void' to parameter expecting synchronous function type
                    if let loaded: Data = try? await newValue?.loadTransferable(type: Data.self) { //.loadTransferable(type: Data.self) asynchronously load an instance of Data from PhotosPickerItem and convert it into a 'Data' type.
                        //stringImage = loaded.base64EncodedString() //We can convert the 'Data' into a base 64 string directly like so, but since we still need to display this 'Data' in type 'Image' and we also need to compress it, we convert it into an instance of UIKits UIImage first, which allows us to compress it with .jpegData(compressionQuality:) and display it with Image(uiImage:)
                        guard let uiImage: UIImage = UIImage(data: loaded) else { return } //Turn Data into UIImage
                        imageItem2 = Image(uiImage: uiImage) //Display Data as an instance of SwiftUI's 'Image'.
                        guard let data: Data = uiImage.jpegData(compressionQuality: 20) else { return } //'loaded' is now compressed as jpeg data. pngData() also works but doesn't compress.
                        stringImage2 = data.base64EncodedString() //Get the base 64 string of the compressed 'loaded'.
                    } else {
                        print("Image selection failed...")
                    }
                }
            }
            if let stringImage2: String = stringImage2 {
                Text("Base64 String:\n \(stringImage2)") //Creating a base64 String from a UIKit UIImage.
                    .frame(height: 100) //String is too long.
                    .truncationMode(.tail)
            } else {
                Text("Base64 String:")
            }
            
            //ALTERNATIVE SOLUTION:
            PhotosPicker(selection: $selectedImage3, matching: .images, label: {
                if imageItem3 == nil { //Show either the default image(.name) or the image url if there's no selected image.
                    ProfilePic(
                        image_url: image_url,
                        points: 100
                    )
                } else if imageItem3 != nil { //Image has been selected from gallery.
                    imageItem3?
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(Color.gray, lineWidth: 1) //Won't be noticeable with default image 'account_circle' since border already black but can be seen on any other image.
                        }
                }
            })
            .onChange(of: selectedImage3) { oldValue, newValue in //If selectedImage3 has changed, then it's no longer empty so just force unwrap.
                Task { //Task is necessary because we can't pass function of type '(PhotosPickerItem?, PhotosPickerItem?) async -> Void' to parameter expecting synchronous function type
                    if let loaded: Data = try? await newValue?.loadTransferable(type: Data.self) { //.loadTransferable(type: Data.self) asynchronously load an instance of Data from PhotosPickerItem and convert it into a 'Data' type.
                        //stringImage = loaded.base64EncodedString() //We can convert the 'Data' into a base 64 string directly like so, but since we still need to display this 'Data' in type 'Image' and we also need to compress it, we convert it into an instance of UIKits UIImage first, which allows us to compress it with .jpegData(compressionQuality:) and display it with Image(uiImage:)
                        guard let uiImage: UIImage = UIImage(data: loaded) else { return } //Turn Data into UIImage
                        imageItem3 = Image(uiImage: uiImage) //Display Data as an instance of SwiftUI's 'Image'.
                        guard let data: Data = uiImage.jpegData(compressionQuality: 20) else { return } //'loaded' is now compressed as jpeg data. pngData() also works but doesn't compress.
                        stringImage3 = data.base64EncodedString() //Get the base 64 string of the compressed 'loaded'.
                    } else {
                        print("Image selection failed...")
                    }
                }
            }
            if let stringImage3: String = stringImage3 {
                Text("Base64 String:\n \(stringImage3)") //Creating a base64 String from a UIKit UIImage.
                    .frame(height: 100) //String is too long.
                    .truncationMode(.tail)
            } else {
                Text("Base64 String:")
            }
        } //VStack
    }
    
    func createImageView() -> some View { //Unused. Returns the View Image(_ name)
        Image("account_circle")
    }
}

#Preview {
    ContentView()
}
