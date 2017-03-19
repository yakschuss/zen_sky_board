defmodule ZenSkyBoard.Web.LightController do
  use ZenSkyBoard.Web, :controller

  alias ZenSkyBoard.Dashboard
  alias ZenSkyBoard.Dashboard.Light
  alias ZenSkyBoard.Web.DashboardChannel

  action_fallback ZenSkyBoard.Web.FallbackController

  def create(conn, %{"light" => light_params}) do
    case Dashboard.create_light(light_params) do
      {:ok, light} ->
        DashboardChannel.broadcast_connect(light)
        conn
        |> put_status(:created)
        |> render("light.json", light: light)


      {:error, changeset} ->
        %{"cpuid" => cpuid} = light_params
        light = Dashboard.get_light_by_cpuid(cpuid)

        Dashboard.update_light(light, light_params)
        DashboardChannel.broadcast_change(light)

        conn
        |> put_status(:no_content)
        |> render("light.json", light: light)
    end
  end

  def update(conn, %{"cpuid" => cpuid, "light" => light_params}) do
    light = Dashboard.get_light_by_cpuid(cpuid)

    with {:ok, %Light{} = light} <- Dashboard.update_light(light, light_params) do
      DashboardChannel.broadcast_change(light)
      conn
      |> put_status(:created)
      |> render("light.json", light: light)
    end
  end

  def delete(conn, %{"cpuid" => cpuid}) do
    light = Dashboard.get_light_by_cpuid(cpuid)
    with {:ok, %Light{}} <- Dashboard.delete_light(light) do
      DashboardChannel.broadcast_delete(cpuid)
      conn
      |> put_status(:ok)
      |> render("light.json", light: light)
    end
  end
end