import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // This means that, if this piece of data can be downcast into a UIImageDataType, then you should execute this line of code in between these two curly braces. We want the setting the IV property to that userPickedImage that we got out of that.
        
        if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedimage
            
            guard let image = CIImage(image: userPickedimage) else {fatalError("Can't convert to CIImage")} // CIImage = Core Image Image. We can also benefit from wrapping it inside a guard statement cuz in the cases where we can actually convert our UIImage into a climage successfully, then we can end up crashing our app w/o knowing what caused it.
            
                // detect isn't called anywhere and we wont get any results back if we run it now. Warning hints at a bug in our code because its saying the ciimage was never used anywhere. We want to pass the image into this method detect so that the image can be used to be classified by our model.
            
            detect(image: image)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    // Create a method that will process that CIImage and get an interpretation or classification. Use the Inception v3 model. All we have to do is to create a new object called model and use the VNCoreMLModel as a container for our mlmodel and our model is called InceptionV3. It creates a new object and now we're tapping into it's model property. We have created a object called model using VNCoreMLModel container and creating a new object of Inceptionv3 and getting it's model property loaded up.
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: Inceptionv3.urlOfModelInThisBundle)) else {
            fatalError("can't load ML Model")
        }
        // This is the model we're going to be using to classify our image. Since this can throw an error, mark it with a "try". This will attempt to perform this op that might throw an error. If successful, then the result is of this line is going to be wrapped as an optional, if it fails, the result of this line will be nil. To guard against those situations where this fails and we end up getting a model that is nil, we don't want to do any more image processing with something thats a nil model. If app crashes on those conditions, we want to know exactly why it did so we want to send an error message to our debug console to know which part failed.
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("Could not access Image")}
            // Going to create a vision coreMLRequest called request and it will equal VNCoreMLRequest and use the one that has a completion handler. Click on VNRequestCompletionHandler placeholder. We will get two things back. One is the request (request), and the next is an error. Code we want to happen inside the completion block when that request has completed is to process the results of that request. Create an object called results. Comes from the completion handler callback .results. And as you see at the moment, its DT is an array of objeects, we'll downcast it "as? to an array of VNClassificationObservations. This class that holds CO after our model has been processed. Want to use a guard statement. Last thing we need to do is to perform the request. Request has a model associated with it but it doesn't actually know which image to perform that classification request on.
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hot Dog!"
                } else {
                    self.navigationItem.title = "Not Hot Dog"
                }
            }
            
            // We're using optional chaining to check to make sure that the results that we get back definitely have a firstResult value, then we're going to use that value to check that it's identifier contains the word "hotdog".
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
        
        // creating a handler that specifies the image we want to classify. It's going to take a CiImage and the image that we're going to input in here is the one that was passed into this method as a param, so the ciImage that we're going to pass in and that image is going to come from the ciImage constant in the IPController. So the image that the user picked gets converted into ciimage then gets passed into this method as a CIImage then gets put into this handler to specify that its the one that we want to classify using our ML model. All we need to do is to write try using the handler to perform the request that we created. The line of code will work as long as it doesn't get any errors. Instead of forcing (try!) to execute this line, execute by wrapping in a do/catch block. All we need to do in order to use a ML model to classify your image. Last thing we need to do before we can run the app and test it out is that we need to call the detect method.
    }
    
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
}

