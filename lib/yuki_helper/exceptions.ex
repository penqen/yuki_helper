defmodule YukiHelper.Exceptions do
  @moduledoc false

  defmodule AccessTokenError do
    defexception [:description]

    @impl true
    def message(exception) do
      "access token is invalid : #{exception.description}"
    end
  end

  defmodule ConfigurationFileError do
    defexception [:file, :description]

    @impl true
    def message(exception) do
      "configure file #{exception.file} #{exception.description}"
    end
  end

  defmodule BadTargetError do
    defexception [:target, description: "target file is not found"]

    @impl true
    def message(exception) do
      "target `#{exception.target}` : #{exception.description}"
    end
  end

  defmodule CompilerError do
    defexception [:compiler, description: "compiler is not found"]

    @impl true
    def message(exception) do
      "`#{exception.compiler}` : #{exception.description}"
    end
  end

  defmodule CompileError do
    defexception [:target, description: "compile error has been occurred"]

    @impl true
    def message(exception) do
      "target: `#{exception.target}` : #{exception.description}"
    end
  end

  defmodule DownloadError do
    defexception [:path, :status, :description]

    @impl true
    def message(exception) do
      "download failed #{exception.path} [#{exception.status}] : #{exception.description}"
    end
  end
end
