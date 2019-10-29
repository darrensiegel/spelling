defmodule Spelling.ContentTest do
  use Spelling.DataCase

  alias Spelling.Content

  describe "words" do
    alias Spelling.Content.Word

    @valid_attrs %{clip: "some clip", reading: true, word: "some word"}
    @update_attrs %{clip: "some updated clip", reading: false, word: "some updated word"}
    @invalid_attrs %{clip: nil, reading: nil, word: nil}

    def word_fixture(attrs \\ %{}) do
      {:ok, word} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_word()

      word
    end

    test "list_words/0 returns all words" do
      word = word_fixture()
      assert Content.list_words() == [word]
    end

    test "get_word!/1 returns the word with given id" do
      word = word_fixture()
      assert Content.get_word!(word.id) == word
    end

    test "create_word/1 with valid data creates a word" do
      assert {:ok, %Word{} = word} = Content.create_word(@valid_attrs)
      assert word.clip == "some clip"
      assert word.reading == true
      assert word.word == "some word"
    end

    test "create_word/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_word(@invalid_attrs)
    end

    test "update_word/2 with valid data updates the word" do
      word = word_fixture()
      assert {:ok, %Word{} = word} = Content.update_word(word, @update_attrs)
      assert word.clip == "some updated clip"
      assert word.reading == false
      assert word.word == "some updated word"
    end

    test "update_word/2 with invalid data returns error changeset" do
      word = word_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_word(word, @invalid_attrs)
      assert word == Content.get_word!(word.id)
    end

    test "delete_word/1 deletes the word" do
      word = word_fixture()
      assert {:ok, %Word{}} = Content.delete_word(word)
      assert_raise Ecto.NoResultsError, fn -> Content.get_word!(word.id) end
    end

    test "change_word/1 returns a word changeset" do
      word = word_fixture()
      assert %Ecto.Changeset{} = Content.change_word(word)
    end
  end

  describe "lists" do
    alias Spelling.Content.List

    @valid_attrs %{name: "some name", week_ending: ~D[2010-04-17]}
    @update_attrs %{name: "some updated name", week_ending: ~D[2011-05-18]}
    @invalid_attrs %{name: nil, week_ending: nil}

    def list_fixture(attrs \\ %{}) do
      {:ok, list} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_list()

      list
    end

    test "list_lists/0 returns all lists" do
      list = list_fixture()
      assert Content.list_lists() == [list]
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert Content.get_list!(list.id) == list
    end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %List{} = list} = Content.create_list(@valid_attrs)
      assert list.name == "some name"
      assert list.week_ending == ~D[2010-04-17]
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      list = list_fixture()
      assert {:ok, %List{} = list} = Content.update_list(list, @update_attrs)
      assert list.name == "some updated name"
      assert list.week_ending == ~D[2011-05-18]
    end

    test "update_list/2 with invalid data returns error changeset" do
      list = list_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_list(list, @invalid_attrs)
      assert list == Content.get_list!(list.id)
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = Content.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Content.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = Content.change_list(list)
    end
  end
end
