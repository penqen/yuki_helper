defmodule YukiHelper.Exceptions.InvalidAccessTokenError do
  defexception [message: "invalid access token"]
end

defmodule YukiHelper.Exceptions.CompileTargetNotFound do
  defexception [message: "could not find a compile target"]
end

defmodule YukiHelper.Exceptions.CompilerNotFound do
  defexception [message: "could not find a compiler"]
end

defmodule YukiHelper.Exceptions.CompileFailed do
  defexception [message: "could not compile a target"]
end

defmodule YukiHelper.Exceptions.DownloadFailed do
  defexception [message: "could not download any file"]
end