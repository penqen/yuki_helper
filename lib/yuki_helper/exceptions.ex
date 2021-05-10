defmodule YukiHelper.Exceptions do
  @moduledoc false

  defmodule AccessTokenError do
    defexception [description: "empty access token"]

    @impl true
    def message(exception) do
      "invalid access token : #{exception.description}"
    end
  end

  defmodule ConfigFileError do
    defexception [:file, description: "config file not found"]

    @impl true
    def message(exception) do
      "#{exception.file} : #{exception.description}"
    end
  end

  defmodule SourceFileError do
    defexception [:source, description: "source file is not found"]

    @impl true
    def message(exception) do
      "`#{exception.source}` : #{exception.description}"
    end
  end

  defmodule LanguageError do
    defexception [:language, description: "language is no not supported"]

    @impl true
    def message(exception) do
      "`#{exception.language}` : #{exception.description}"
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
    defexception [:source, description: "compile error has been occurred"]

    @impl true
    def message(exception) do
      "target: `#{exception.source}` : #{exception.description}"
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
