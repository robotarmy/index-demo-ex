defmodule BinaryTreeServerTest do
  use ExUnit.Case
  doctest BinaryTreeServer

  @doc """

  This file tests simple properties of a
  Binary Tree Datastructure.

  Since a basic binary tree datastructure doesn't rebalance
  only simple properties are checked.

  """



  alias BinaryTreeServer, as: M
  test "#insert_key into an empty leaf / empty tree - constructs tree" do

    tree = M.insert_key(:empty, 10, 100)
    assert tree.key == 10
    assert tree.values == [100]
    assert tree.left == :empty
    assert tree.right == :empty
  end

  test "#insert larger key into tree, constucts sub tree with right ordering property" do
    tree = M.insert_key(:empty, 10, "A")
    tree2 = M.insert_key(tree, 100, "B")
    tree3 = M.insert_key(tree2, 1000, "C")

    assert :empty == tree.left, "left tree of initial tree empty"
    assert :empty == tree2.left, "left tree of tree2 empty"
    assert :empty == tree3.left, "left tree of tree3 empty"

    # unbalanced binary trees have this usually
    # undesireable property of turning into
    # a min-max ordered linked list
    assert ["A"]  == tree3.values, "tree3 doesn't mutate root"
    assert ["B"]  == tree3.right.values, "tree3 stores second insert right"
    assert ["C"]  == tree3.right.right.values, "tree3 stores third insert right of second"
  end

  test "#insert smaller key into tree, constucts sub tree with left ordering property" do
    tree = M.insert_key(:empty, 1000, "A")
    tree2 = M.insert_key(tree, 100, "B")
    tree3 = M.insert_key(tree2, 10, "C")

    assert :empty == tree.right, "right tree of initial tree empty"
    assert :empty == tree2.right, "right tree of tree2 empty"
    assert :empty == tree3.right, "right tree of tree3 empty"

    assert ["A"]  == tree3.values, "tree3 doesn't mutate root"
    assert ["B"]  == tree3.left.values, "tree3 stores second insert left"
    assert ["C"]  == tree3.left.left.values, "tree3 stores third insert left of second"
  end

  test "#insert smaller key and larger into tree, constucts sub tree with left and right branches" do

    tree = M.insert_key(:empty, 100, "A")
    tree2 = M.insert_key(tree, 50, "B")
    tree3 = M.insert_key(tree2, 150, "C")

    assert ["A"] == tree3.values, "no change of root"
    assert tree3.key < tree3.right.key, "right key #{tree3.right.key} is > root #{tree3.key}"
    assert tree3.key > tree3.left.key, "right key is > root"
  end

  test "#insert smaller key and larger into filled tree, constructs two new sub trees" do

    tree =
      M.insert_key(:empty, 100, "A")
      |> M.insert_key(50, "B")
      |> M.insert_key(150, "C")
      |> M.insert_key(20, "D") # smaller
      |> M.insert_key(200, "E") # larger

    assert tree.left.left.key == 20 , "smallest value went left most"
    assert tree.left.left.left == :empty , "new left subtree is unconnected left"
    assert tree.left.left.right == :empty , "new left subtree is unconnected right"

    assert tree.right.right.key == 200 , "largest value went right most"
    assert tree.right.right.left == :empty , "new right subtree is unconnected left"
    assert tree.right.right.right == :empty , "new right subtree is unconnected right"
  end


  test "# duplicate keys are supported and append values into matching key with descending order" do
    tree = M.insert_key(:empty, 100, "X")
    tree2 = M.insert_key(tree, 100, "Y")
    tree3 = M.insert_key(tree2, 100, "Z")

    assert ["Z","Y","X"] == tree3.values, "Order of duplicated key entries is max -> min "
  end
end
