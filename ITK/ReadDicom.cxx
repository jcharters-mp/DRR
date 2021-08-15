/*=========================================================================
 *
 *  Copyright NumFOCUS
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0.txt
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *=========================================================================*/

// Read a CT volume in DICOM format and export to an nrrd file
// This function is an edited version of ITK's DicomSeriesReadImageWrite2.cxx
// John Charters
//
// Apache 2.0 license guidelines:
// License and Notice are provided together with this function
// List of changes made to DicomSeriesReadImageWrite2.cxx
// - many original comments removed for brevity

#include "itkImage.h"
#include "itkGDCMImageIO.h"
#include "itkGDCMSeriesFileNames.h"
#include "itkImageSeriesReader.h"
#include "itkImageFileWriter.h"

int main(int argc, char* argv[])
{
    if (argc < 3)
    {
        std::cerr << std::endl;
        std::cerr << "Read a CT volume in DICOM format and export to an nrrd file \n";
        std::cerr << "This function is an edited verion of ITK's DicomSeriesReadImageWrite2.cxx \n";
        std::cerr << "John Charters \n\n";
        std::cerr << "Usage: .\\ReadDicom DicomDirectory outputFileName [seriesName] \n\n";

        return EXIT_FAILURE;
    }

    // we assume a signed short pixel type that is commonly used for X-ray CT scanners
    using PixelType = signed short;

    // image is three-dimensional
    constexpr unsigned int Dimension = 3;
    using ImageType = itk::Image<PixelType, Dimension>;

    using ReaderType = itk::ImageSeriesReader<ImageType>;
    ReaderType::Pointer reader = ReaderType::New();

    // GDCM class is used for DICOM format
    using ImageIOType = itk::GDCMImageIO;
    ImageIOType::Pointer dicomIO = ImageIOType::New();

    reader->SetImageIO(dicomIO);

    // GDCM identifies filenames that belong together within a directory
    using NamesGeneratorType = itk::GDCMSeriesFileNames;
    NamesGeneratorType::Pointer nameGenerator = NamesGeneratorType::New();

    nameGenerator->SetUseSeriesDetails(true);
    nameGenerator->AddSeriesRestriction("0008|0021"); // SeriesDate attribute

    nameGenerator->SetDirectory(argv[1]);


    try
    {
        std::cout << std::endl << "The directory: " << std::endl;
        std::cout << std::endl << argv[1] << std::endl << std::endl;
        std::cout << "Contains the following DICOM Series: ";
        std::cout << std::endl << std::endl;

        // list of DICOM series
        using SeriesIdContainer = std::vector<std::string>;
        const SeriesIdContainer& seriesUID = nameGenerator->GetSeriesUIDs();

        auto seriesItr = seriesUID.begin();
        auto seriesEnd = seriesUID.end();
        while (seriesItr != seriesEnd)
        {
            std::cout << seriesItr->c_str() << std::endl;
            ++seriesItr;
        }
 
        std::string seriesIdentifier;

        if (argc > 3) // If no optional series identifier
        {
            seriesIdentifier = argv[3];
        }
        else
        {
            seriesIdentifier = seriesUID.begin()->c_str();
        }

        // now one series is selected
        std::cout << std::endl << std::endl;
        std::cout << "Now reading series: " << std::endl << std::endl;
        std::cout << seriesIdentifier << std::endl;
        std::cout << std::endl << std::endl;

        // ask for all of the filenames associated to this series
        using FileNamesContainer = std::vector<std::string>;
        FileNamesContainer fileNames;

        fileNames = nameGenerator->GetFileNames(seriesIdentifier);

        reader->SetFileNames(fileNames);

        try
        {
            reader->Update();
        }
        catch (const itk::ExceptionObject& ex)
        {
            std::cout << ex << std::endl;
            return EXIT_FAILURE;
        }


        // save the volumetric image in another file
        using WriterType = itk::ImageFileWriter<ImageType>;
        WriterType::Pointer writer = WriterType::New();

        writer->SetFileName(argv[2]);

        writer->SetInput(reader->GetOutput());

        std::cout << "Writing the image as " << std::endl << std::endl;
        std::cout << argv[2] << std::endl << std::endl;

        try
        {
            writer->Update();
        }
        catch (const itk::ExceptionObject& ex)
        {
            std::cout << ex << std::endl;
            return EXIT_FAILURE;
        }
    }
    catch (const itk::ExceptionObject& ex)
    {
        std::cout << ex << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
