if false do
  defmodule Harald.Spec.Parser do
    @moduledoc false

    alias Harald.Parser.Ast
    require Logger

    def parse({_section, _spec}, state), do: state

    defp ast_map(type, name, prefix)

    defp ast_map(:empty, _, _) do
      %{
        arrayed_data: false,
        deserializers: [],
        generators: [],
        serializers: [],
        processed_parameters: []
      }
    end

    defp ast_map(type, name, prefix) do
      %{
        arrayed_data: false,
        deserializers: ast_map_deserializers(type, name, prefix),
        generators: ast_map_generators(type, name, prefix),
        subevent_name: ast_subevent_name(type, name),
        parameter_var: Ast.var(:v1),
        parameter_index: 1,
        processed_parameters: [],
        serializers: ast_map_serializers(type, name, prefix)
      }
    end

    defp ast_subevent_name(:subevent, {_, subevent_name}), do: subevent_name

    defp ast_subevent_name(_, _), do: nil

    defp ast_map_generators(:command, name, prefix) do
      [
        quote do
          def generate(unquote(name)) do
            gen all(bin <- StreamData.constant(unquote({:<<>>, [], prefix ++ [0]}))) do
              <<bin::binary>>
            end
          end
        end
      ]
    end

    defp ast_map_generators(:event, name, prefix) do
      [
        quote do
          def generate(unquote(name)) do
            gen all(
                  bin <- StreamData.constant(unquote({:<<>>, [], prefix})),
                  parameters = <<>>,
                  parameter_total_length = byte_size(parameters)
                ) do
              <<bin::binary, parameter_total_length, parameters::binary>>
            end
          end
        end
      ]
    end

    defp ast_map_generators(:subevent, name, prefix) do
      [
        quote do
          def generate(unquote(name)) do
            gen all(
                  bin <- StreamData.constant(unquote({:<<>>, [], prefix})),
                  parameters = <<>>,
                  parameter_total_length = byte_size(parameters)
                ) do
              <<bin::binary, parameter_total_length, parameters::binary>>
            end
          end
        end
      ]
    end

    defp ast_map_generators(type, name, prefix) when type in [:return, :generic_access_profile] do
      [
        quote do
          def generate({unquote(type), unquote(name)}) do
            gen all(bin <- StreamData.constant(unquote({:<<>>, [], prefix}))) do
              <<bin::binary>>
            end
          end
        end
      ]
    end

    defp spec_unit(name, parameters), do: %{name: name, parameters: parameters}
  end
end
