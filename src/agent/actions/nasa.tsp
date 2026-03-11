import "@typespec/http";
import "@microsoft/typespec-m365-copilot";
import "../env.tsp";

using TypeSpec.Http;
using TypeSpec.M365.Copilot.Actions;

@service
@server(NasaAPI.SERVER_URL)
@actions(NasaAPI.ACTIONS_METADATA)
namespace NasaAPI {
  /**
   * Metadata for the NASA API actions.
   */
  const ACTIONS_METADATA = #{
    nameForHuman: "NASA",
    descriptionForHuman: "Get NASA's Astronomy Picture of the Day and search Mars rover photos.",
    descriptionForModel: "Retrieve NASA's Astronomy Picture of the Day (APOD) with explanations, and search photos taken by Mars rovers. Use this when the user asks about space, astronomy, NASA images, or Mars.",
    legalInfoUrl: "https://www.nasa.gov/about/highlights/HP_Privacy.html",
    privacyPolicyUrl: "https://www.nasa.gov/about/highlights/HP_Privacy.html"
  };

  /**
   * The base URL for the NASA API.
   */
  const SERVER_URL = Environment.NASA_API_URL;

  /**
   * Get NASA's Astronomy Picture of the Day.
   * Returns the picture, title, explanation, and media type for a given date.
   * @param api_key The NASA API key.
   * @param date The date for the APOD in YYYY-MM-DD format. Defaults to today.
   */
  @route("/planetary/apod")
  @card(#{
    dataPath: "$",
    file: "adaptiveCards/nasaApod.json",
    properties: #{
      title: "$.title",
      url: "$.url"
    }
  })
  @get op getApod(
    @query api_key: string = Environment.NASA_API_KEY,
    @query date?: string
  ): string;

  /**
   * Search photos taken by NASA's Mars rovers.
   * @param api_key The NASA API key.
   * @param sol The Martian sol (day) to retrieve photos from. Default is 1000.
   * @param camera The rover camera to filter by (e.g., FHAZ, RHAZ, NAVCAM, MAST). Optional.
   */
  @route("/mars-photos/api/v1/rovers/curiosity/photos")
  @card(#{
    dataPath: "$.photos",
    file: "adaptiveCards/nasaMarsPhotos.json",
    properties: #{
      title: "$.camera.full_name",
      url: "$.img_src"
    }
  })
  @get op getMarsPhotos(
    @query api_key: string = Environment.NASA_API_KEY,
    @query sol: integer = 1000,
    @query camera?: string
  ): string;
}
