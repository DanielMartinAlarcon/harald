defmodule Harald.HCITest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias Harald.HCI

  doctest Harald.HCI, import: true

  describe "7.7.65.2 LE Advertising Report event" do
    test "base case" do
      bin = <<
        # Packet Type - Event
        4,
        # Event Code - LE Meta Event
        62,
        # Length
        62,
        # Sub-event Code - Advertising Report
        2,
        # Num_Reports
        5,
        # Arrayed data
        # Event_Type[i] (1 octet)
        <<0, 1, 2, 3, 4>>,
        # Address_Type[i] (1 octet)
        <<1, 2, 3, 4, 5>>,
        # Address[i] (6 octets)
        <<
          (<<1, 2, 3, 4, 5, 6>>),
          <<2, 3, 4, 5, 6, 7>>,
          <<3, 4, 5, 6, 7, 8>>,
          <<4, 5, 6, 7, 8, 9>>,
          (<<5, 6, 7, 8, 9, 10>>)
        >>,
        # Length_Data[i] (1 octets)
        <<0, 10, 0, 0, 0>>,
        # Data[i] (Length_Data[i])
        <<
          # Ad Structure 1
          (<<>>),
          # Ad Structure 2
          <<
            # Length
            9,
            # AD Type - Service Data - 32 bit UUID
            32,
            # AD Data
            (<<
               # UUID
               (<<1, 2, 3, 4>>),
               # Service Data
               (<<1, 2, 3, 4>>)
             >>)
          >>,
          # Ad Structure 3
          <<>>,
          # Ad Structure 4
          <<>>,
          # Ad Structure 5
          (<<>>)
        >>,
        # RSSI[i] (1 octet)
        (<<0x7F, -127, -1, 0, 20>>)
      >>

      data = %{
        :event_code => "HCI_LE_Meta",
        :reports => [
          %{
            "Address" => 6_618_611_909_121,
            "Address_Type" => 1,
            "Data" => [],
            "Event_Type" => 0,
            "RSSI" => "RSSI is not available"
          },
          %{
            "Address" => 7_722_435_347_202,
            "Address_Type" => 2,
            "Data" => [
              %{
                :id => "Service Data - 32-bit UUID",
                :type => :generic_access_profile,
                "UUID" => 16_909_060,
                "data" => <<1, 2, 3, 4>>
              }
            ],
            "Event_Type" => 1,
            "RSSI" => -127
          },
          %{
            "Address" => 8_826_258_785_283,
            "Address_Type" => 3,
            "Data" => [],
            "Event_Type" => 2,
            "RSSI" => -1
          },
          %{
            "Address" => 9_930_082_223_364,
            "Address_Type" => 4,
            "Data" => [],
            "Event_Type" => 3,
            "RSSI" => 0
          },
          %{
            "Address" => 11_033_905_661_445,
            "Address_Type" => 5,
            "Data" => [],
            "Event_Type" => 4,
            "RSSI" => 20
          }
        ],
        :type => :event,
        "Num_Reports" => 5,
        "Subevent_Code" => "HCI_LE_Advertising_Report"
      }

      assert data == HCI.deserialize(bin)
    end
  end
end
