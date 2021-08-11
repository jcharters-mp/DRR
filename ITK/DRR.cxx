#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkResampleImageFilter.h"
#include "itkCenteredEuler3DTransform.h"
#include "itkNearestNeighborInterpolateImageFunction.h"
#include "itkImageRegionIteratorWithIndex.h"
#include "itkRescaleIntensityImageFilter.h"
#include "itkRayCastInterpolateImageFunction.h"

void usage()
{
  std::cerr << "\n";
  std::cerr << "Digitally reconstructed radiographs for Novalis ExacTrac \n";
  std::cerr << "This function is an edited version of ITK's DigitallyReconstructedRadiograph1.cxx \n";
  std::cerr << "John Charters \n\n";
  std::cerr << "Usage: .\\DRR <options> [input] \n\n";
  std::cerr << "    <-h> Displays the usage information \n";
  std::cerr << "    <-size int int> Pixel dimensions of the DRR [pix] \n";
  std::cerr << "    <-res float float> Pixel spacing of the DRR [mm/pix] \n";
  std::cerr << "    <-iso float float float> Isocenter of the CT volume [mm] \n";
  std::cerr << "    <-foc float float float> Focal point of the X-ray tube [mm] \n";
  std::cerr << "    <-dirCos float*16> Direction cosines of the DRR \n";
  std::cerr << "    <-orig float float float> Upper-left corner of the DRR [mm] \n";
  std::cerr << "    <-thresh float> CT number threshold [HU] \n";
  std::cerr << "    <-transl float float float> X-ray correction translations [mm] \n";
  std::cerr << "    <-rot float float float> X-ray correction rotations [deg] \n";
  std::cerr << "    <-o file> Output image filename \n";
  std::cerr << "    [input] CT volume nrrd file \n\n";

  exit(1);
}

int main(int argc, char * argv[])
{
  char * input_name = nullptr;
  char * output_name = nullptr;

  bool ok;

  // pixel dimensions [pix]
  int W = 0;
  int H = 0;

  // pixel spacing [mm/pix]
  float sX = 0;
  float sY = 0;

  // isocenter [mm]
  float isoX = 0;
  float isoY = 0;
  float isoZ = 0;

  // focal point [mm]
  float focX = 0;
  float focY = 0;
  float focZ = 0;

  // direction cosines matrix
  float dirCos[3][3] = {
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0}
  };

  // DRR origin [mm]
  float origX = 0;
  float origY = 0;
  float origZ = 0;

  // intensity threshold [uint8]
  float thresh = 0;

  // X-ray correction translations [mm]
  float translX = 0;
  float translY = 0;
  float translZ = 0;

  // X-ray correction rotations [deg]
  float rotX = 0;
  float rotY = 0;
  float rotZ = 0;


  // parse command line parameters
  while (argc > 1)
  {
    ok = false;

    if ((ok == false) && (strcmp(argv[1], "-h") == 0))
    {
      argc--;
      argv++;
      ok = true;
      usage();
    }

    if ((ok == false) && (strcmp(argv[1], "-size") == 0))
    {
      argc--;
      argv++;
      ok = true;
      W = std::stod(argv[1]);
      argc--;
      argv++;
      H = std::stod(argv[1]);
      argc--;
      argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-res") == 0))
    {
      argc--;
      argv++;
      ok = true;
      sX = std::stod(argv[1]);
      argc--;
      argv++;
      sY = std::stod(argv[1]);
      argc--;
      argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-iso") == 0))
    {
        argc--;
        argv++;
        ok = true;
        isoX = std::stod(argv[1]);
        argc--;
        argv++;
        isoY = std::stod(argv[1]);
        argc--;
        argv++;
        isoZ = std::stod(argv[1]);
        argc--;
        argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-foc") == 0))
    {
      argc--;
      argv++;
      ok = true;
      focX = std::stod(argv[1]);
      argc--;
      argv++;
      focY = std::stod(argv[1]);
      argc--;
      argv++;
      focZ = std::stod(argv[1]);
      argc--;
      argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-dirCos") == 0))
    {
      argc--;
      argv++;
      ok = true;
      dirCos[0][0] = std::stod(argv[1]);
      argc--;
      argv++;
      dirCos[1][0] = std::stod(argv[1]);
      argc--;
      argv++;
      dirCos[2][0] = std::stod(argv[1]);
      argc--;
      argv++;
      dirCos[0][1] = std::stod(argv[1]);
      argc--;
      argv++;
      dirCos[1][1] = std::stod(argv[1]);
      argc--;
      argv++;
      dirCos[2][1] = std::stod(argv[1]);
      argc--;
      argv++;
      dirCos[0][2] = std::stod(argv[1]);
      argc--;
      argv++;
      dirCos[1][2] = std::stod(argv[1]);
      argc--;
      argv++;
      dirCos[2][2] = std::stod(argv[1]);
      argc--;
      argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-orig") == 0))
    {
      argc--;
      argv++;
      ok = true;
      origX = std::stod(argv[1]);
      argc--;
      argv++;
      origY = std::stod(argv[1]);
      argc--;
      argv++;
      origZ = std::stod(argv[1]);
      argc--;
      argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-thresh") == 0))
    {
      argc--;
      argv++;
      ok = true;
      thresh = std::stod(argv[1]);
      argc--;
      argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-transl") == 0))
    {
        argc--;
        argv++;
        ok = true;
        translX = std::stod(argv[1]);
        argc--;
        argv++;
        translY = std::stod(argv[1]);
        argc--;
        argv++;
        translZ = std::stod(argv[1]);
        argc--;
        argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-rot") == 0))
    {
        argc--;
        argv++;
        ok = true;
        rotX = std::stod(argv[1]);
        argc--;
        argv++;
        rotY = std::stod(argv[1]);
        argc--;
        argv++;
        rotZ = std::stod(argv[1]);
        argc--;
        argv++;
    }

    if ((ok == false) && (strcmp(argv[1], "-o") == 0))
    {
      argc--;
      argv++;
      ok = true;
      output_name = argv[1];
      argc--;
      argv++;
    }

    if (ok == false)
    {
      if (input_name == nullptr)
      {
        input_name = argv[1];
        argc--;
        argv++;
      }
      else
      {
        std::cerr << "ERROR: Can not parse argument " << argv[1] << std::endl;
        usage();
      }
    }
  }


  // input and output must both be three-dimensional
  constexpr unsigned int Dimension = 3;
  using InputPixelType = short;
  using OutputPixelType = unsigned char;
  using InputImageType = itk::Image<InputPixelType, Dimension>;
  using OutputImageType = itk::Image<OutputPixelType, Dimension>;

  InputImageType::Pointer image;

  // load CT with reader
  if (input_name)
  {
    using ReaderType = itk::ImageFileReader<InputImageType>;
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName(input_name);

    try
    {
      reader->Update();
    }
    catch (const itk::ExceptionObject & err)
    {
      std::cerr << "ERROR: ExceptionObject caught !" << std::endl;
      std::cerr << err << std::endl;
      return EXIT_FAILURE;
    }

    image = reader->GetOutput();
  }
  else
  {
      std::cerr << "ERROR: No image specified!" << std::endl;
      return EXIT_FAILURE;
  }


  // generates coordinates for each DRR pixel to determine ray tracing equations
  using FilterType = itk::ResampleImageFilter<InputImageType, InputImageType>;
  FilterType::Pointer filter = FilterType::New();

  filter->SetInput(image);
  filter->SetDefaultPixelValue(0);

  // an Euler transformation positions the input volume
  using TransformType = itk::CenteredEuler3DTransform<double>;
  TransformType::Pointer transform = TransformType::New();

  transform->SetComputeZYX(true); // Go To Definition for more info on order
  
  TransformType::OutputVectorType translation;

  // make -ve for X-ray correction shifts
  translation[0] = -translX;
  translation[1] = -translY;
  translation[2] = -translZ;

  const double dtr = (std::atan(1.0) * 4.0) / 180.0; // deg to rad

  transform->SetTranslation(translation);
  transform->SetRotation(dtr * rotX, dtr * rotY, dtr * rotZ);
  

  InputImageType::PointType   imOrigin = image->GetOrigin();
  InputImageType::SpacingType imRes = image->GetSpacing();

  using InputImageRegionType = InputImageType::RegionType;
  using InputImageSizeType = InputImageRegionType::SizeType;

  InputImageRegionType imRegion = image->GetBufferedRegion();
  InputImageSizeType   imSize = imRegion.GetSize();

  // shift coordinates relative to CT isocenter
  imOrigin[0] -= isoX;
  imOrigin[1] -= isoY;
  imOrigin[2] -= isoZ;

  image->SetOrigin(imOrigin);

  // center of CT rotations is at linac isocenter
  TransformType::InputPointType center;

  center[0] = 0;
  center[1] = 0;
  center[2] = 0;

  transform->SetCenter(center);


  // reposition x-ray source such that it moves with the DRR image around the input volume
  // this coupling mimics the rigid geometry of the x-ray gantry
  using InterpolatorType =
    itk::RayCastInterpolateImageFunction<InputImageType, double>;
  InterpolatorType::Pointer interpolator = InterpolatorType::New();

  interpolator->SetTransform(transform);
  interpolator->SetThreshold(thresh);
  InterpolatorType::InputPointType focalpoint;

  focalpoint[0] = focX;
  focalpoint[1] = focY;
  focalpoint[2] = focZ;

  interpolator->SetFocalPoint(focalpoint);


  // having initialized the interpolator, we pass the object to the resample filter
  interpolator->Print(std::cout);

  filter->SetInterpolator(interpolator);
  filter->SetTransform(transform);
 
  InputImageType::SizeType size;

  size[0] = W; // [pix]
  size[1] = H; // [pix]
  size[2] = 1;  // only one slice

  filter->SetSize(size);

  InputImageType::SpacingType spacing;

  spacing[0] = sX;  // [mm]
  spacing[1] = sY;  // [mm]
  spacing[2] = 1.0; // slice thickness of the 2D DRR image [mm]

  filter->SetOutputSpacing(spacing);

  // direction cosines matrix
  OutputImageType::DirectionType outdir;

  outdir[0][0] = dirCos[0][0]; outdir[0][1] = dirCos[0][1]; outdir[0][2] = dirCos[0][2];
  outdir[1][0] = dirCos[1][0]; outdir[1][1] = dirCos[1][1]; outdir[1][2] = dirCos[1][2];
  outdir[2][0] = dirCos[2][0]; outdir[2][1] = dirCos[2][1]; outdir[2][2] = dirCos[2][2];

  filter->SetOutputDirection(outdir);


  // DRR origin
  double origin[Dimension];
  
  origin[0] = origX;
  origin[1] = origY;
  origin[2] = origZ;

  filter->SetOutputOrigin(origin);


  // output of resample filter is passed to a writer
  if (output_name)
  {
    using RescaleFilterType =
      itk::RescaleIntensityImageFilter<InputImageType, OutputImageType>;
    RescaleFilterType::Pointer rescaler = RescaleFilterType::New();
    rescaler->SetOutputMinimum(0);
    rescaler->SetOutputMaximum(255);
    rescaler->SetInput(filter->GetOutput());

    using WriterType = itk::ImageFileWriter<OutputImageType>;
    WriterType::Pointer writer = WriterType::New();

    writer->SetFileName(output_name);
    writer->SetInput(rescaler->GetOutput());

    try
    {
      std::cout << "Writing image: " << output_name << std::endl;
      writer->Update();
    }
    catch (const itk::ExceptionObject & err)
    {
      std::cerr << "ERROR: ExceptionObject caught !" << std::endl;
      std::cerr << err << std::endl;
    }
  }
  else
  {
    filter->Update();
  }

  return EXIT_SUCCESS;
}
